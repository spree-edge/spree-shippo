require_dependency 'spree/shipping_calculator'

module SpreeShippo
  module Spree
    module Calculator::Shipping
      class UspsPriorityMailExpressCalculator < ::Spree::ShippingCalculator
        include ShippoConcern

        def self.description
          ::Spree.t(:usps_priority_mail_express)
        end

        def compute_package(_package)
          rates = get_rates(_package)

          rate = rates.select{|rate| rate['servicelevel']['token'] == KW['USPS_PRIORITY_MAIL_EXPRESS']}
          if rate.count > 0
            return {'cost': rate.first['amount'], 'courier_id': rate.first['object_id']}
          else
            nil
          end
        end
      end
    end
  end
end
