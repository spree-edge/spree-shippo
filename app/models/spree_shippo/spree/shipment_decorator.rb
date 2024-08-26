module SpreeShippo
  module Spree
    module ShipmentDecorator
      include ShippoConcern

      def get_tracking_details(number)
        return nil if number.blank?

        carrier = api_key.include?('test') ? 'shippo' : 'usps',number
        data = get_tracking(carrier, number)

        data if data.key?("carrier")
      end

      private

      def api_key
        Shippo::API.token
      end
    end
  end
end

::Spree::Shipment.prepend ::SpreeShippo::Spree::ShipmentDecorator
