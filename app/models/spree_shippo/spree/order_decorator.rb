module SpreeShippo
  module Spree
    module OrderDecorator
      BOX_DIMENSIONS = { length: 6, width: 3, height: 2, weight: 4 }.freeze

      def get_user_return_label(line_item)
        create_and_store_label(line_item, 'Ground Advantage', :item_box_return_label)
      end

      def get_user_shipping_label(line_item)
        create_and_store_label(line_item, 'Priority Mail', :item_box_shipping_label)
      end

      private

      def create_and_store_label(line_item, preferred_service, label_column)
        stock_location = shipments.first.stock_location
        shipping_address = line_item.order.shipping_address
        order = line_item.order

        params = build_shippo_params(stock_location, shipping_address, order, BOX_DIMENSIONS)
        params[:customs_declaration] = create_customs_declaration_if_needed(shipping_address)

        begin
          shippo_shipment = Shippo::Shipment.create(params)
          label_url, _ = generate_label(shippo_shipment, preferred_service)

          line_item.update_column(label_column, label_url) if label_url.present?
        rescue => e
          Rails.logger.error("Error generating label: #{e.message}")
          raise e
        end
      end

      def build_shippo_params(stock_location, shipping_address, order, dimensions)
        {
          async: false,
          address_from: build_address(stock_location),
          address_to: build_address(shipping_address, order),
          parcels: build_parcel(dimensions),
          extra: { reference_1: "Order number: #{order.number}" }
        }
      end

      def build_address(location, order = nil)
        {
          name: [location.try(:firstname), location.try(:lastname)].compact.join(' ').presence || location.try(:name),
          company: location.respond_to?(:company) ? location.company : '',
          street1: location.address1,
          city: location.city,
          state: location.state&.abbr,
          zip: location.zipcode,
          country: location.country.iso,
          phone: location.phone.presence || '000-000-0000', # Ensure a fallback value
          email: order&.email
        }
      end

      def build_parcel(dimensions)
        {
          length: dimensions[:length],
          width: dimensions[:width],
          height: dimensions[:height],
          distance_unit: :in,
          weight: dimensions[:weight],
          mass_unit: :oz
        }
      end

      def create_customs_declaration_if_needed(shipping_address)
        return unless shipping_address.country.iso == 'CA'

        customs_item = {
          description: 'cardboard box',
          quantity: 1,
          net_weight: 1,
          mass_unit: 'g',
          value_amount: '1',
          value_currency: 'USD',
          tariff_number: '',
          origin_country: 'US'
        }

        created_item = Shippo::CustomsItem.create(customs_item)

        declaration_params = {
          contents_type: 'MERCHANDISE',
          non_delivery_option: 'ABANDON',
          certify: true,
          certify_signer: store.name,
          items: [created_item[:object_id]]
        }

        Shippo::CustomsDeclaration.create(declaration_params)[:object_id]
      end

      def generate_label(shippo_shipment, preferred_service)
        shippo_rates = shippo_shipment.rates
        preferred_rate = shippo_rates.find { |rate| rate['servicelevel']['name'] == preferred_service } || shippo_rates.first
      
        if preferred_rate.nil?
          raise StandardError, "No available rates found for the preferred service: #{preferred_service}"
        end
      
        transaction = Shippo::Transaction.create(rate: preferred_rate['object_id'], async: false)
      
        if transaction['status'] == 'ERROR'
          error_messages = transaction['messages'].map { |msg| "#{msg['source']}: #{msg['text']}" }.join(', ')
          Rails.logger.error("Shippo Label Generation Error: #{error_messages}")
          raise StandardError, "Error generating label: #{error_messages}"
        end
      
        [transaction['label_url'], shippo_rates]
      end
      
    end
  end
end

::Spree::Order.prepend ::SpreeShippo::Spree::OrderDecorator
