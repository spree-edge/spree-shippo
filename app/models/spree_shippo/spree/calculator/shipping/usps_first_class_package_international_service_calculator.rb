require_dependency 'spree/shipping_calculator'

module SpreeShippo
  module Spree
    module Calculator::Shipping
      class UspsFirstClassPackageInternationalServiceCalculator < ::Spree::ShippingCalculator
        include ShippoConcern

        def self.description
          ::Spree.t(:usps_first_class_package_international_service)
        end

        def compute_package(_package)
          rates = get_rates(_package)
          
          rate = rates.select {|rate| rate['servicelevel']['token'] == KW['USPS_FIRST_CLASS_PACKAGE_INTERNATIONAL_SERVICE']}
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
