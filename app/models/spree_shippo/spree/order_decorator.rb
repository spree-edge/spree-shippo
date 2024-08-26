module SpreeShippo
  module Spree
    module OrderDecorator

      BOX_DIMENSIONS = { length: 6, width: 3, height: 2, weight: 4 }.freeze

      def get_user_return_label(line_item)
        stock_location = self.shipments.first.stock_location
        shipping_address = line_item.order.shipping_address
        order = line_item.order

        params = build_shippo_params(stock_location, shipping_address, order, BOX_DIMENSIONS)
        params[:customs_declaration] = create_customs_declaration if shipping_address.country.iso == 'CA'

        shippo_shipment = Shippo::Shipment.create(params)
        label_url = generate_label(shippo_shipment, 'Ground Advantage')

        line_item.update_column(:item_box_return_label, label_url) if label_url.present?
      end

      def get_user_shipping_label(line_item)
        stock_location = self.shipments.first.stock_location
        shipping_address = line_item.order.shipping_address
        order = line_item.order

        params = build_shippo_params(stock_location, shipping_address, order, BOX_DIMENSIONS)
        params[:customs_declaration] = create_customs_declaration_if_canadian if shipping_address.country_id == 38

        shippo_shipment = Shippo::Shipment.create(params)
        label_url = generate_label(shippo_shipment, 'Priority Mail')

        line_item.update_column(:item_box_shipping_label, label_url) if label_url.present?
      end

      private

      def build_shippo_params(stock_location, shipping_address, order, dimensions)
        {
          async: false,
          address_from: build_address(stock_location),
          address_to: build_address(shipping_address, order),
          parcels: {
            length: dimensions[:length],
            width: dimensions[:width],
            height: dimensions[:height],
            distance_unit: :in,
            weight: dimensions[:weight],
            mass_unit: :oz
          },
          extra: { reference_1: "Order number:- #{order.number}" }
        }
      end

      def build_address(location, order = nil)
        {
          name: location.try(:firstname) && location.try(:lastname) ? 
          "#{location.firstname} #{location.lastname}" : location.try(:name),
          company: location.respond_to?(:company) ? location.company : '',
          street1: location.address1,
          city: location.city,
          state: location.state&.abbr,
          zip: location.zipcode,
          country: location.country.iso,
          phone: location.phone,
          email: order&.email
        }
      end

      def create_customs_declaration
        custom_item = {
          description: "cardboard box",
          quantity: 1,
          net_weight: 1,
          mass_unit: "g",
          value_amount: "1",
          value_currency: "USD",
          tariff_number: "",
          origin_country: "US"
        }

        customs_item = Shippo::CustomsItem.create(custom_item)
        declaration_params = {
          contents_type: "MERCHANDISE",
          non_delivery_option: "ABANDON",
          certify: true,
          certify_signer: Spree::Store.current.name,
          items: [customs_item[:object_id]]
        }

        Shippo::CustomsDeclaration.create(declaration_params)[:object_id]
      end

      def create_customs_declaration_if_canadian
        customs_item = {
          description: "Item box",
          quantity: 1,
          net_weight: "4",
          mass_unit: "oz",
          value_amount: "1",
          value_currency: "USD",
          tariff_number: "",
          origin_country: "US"
        }

        declaration_params = {
          contents_type: "MERCHANDISE",
          non_delivery_option: "RETURN",
          certify: true,
          certify_signer: "Simon Kreuz",
          incoterm: "DDU",
          items: [customs_item]
        }

        Shippo::CustomsDeclaration.create(declaration_params)[:object_id]
      end

      def generate_label(shippo_shipment, preferred_service)
        shippo_rate = shippo_shipment.rates
        rate = shippo_rate.detect { |rate| rate['servicelevel']['name'] == preferred_service } || shippo_rate.first
        Shippo::Transaction.create({ "rate": rate['object_id'], "async": false })['label_url']
      end

    end
  end
end

::Spree::Order.prepend ::SpreeShippo::Spree::OrderDecorator
