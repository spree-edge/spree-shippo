module SpreeShippo
  module Spree
    module Stock
      module EstimatorDecorator
        include ShippoConcern

        private

        def calculate_shipping_rates(package, ui_filter)
          p "calculate_shipping_rates"
          shipping_methods(package, ui_filter).map do |shipping_method|
            cost = shipping_method.calculator.compute(package)
            
            next unless cost

            if cost.is_a?(Hash)
              shipping_method.shipping_rates.new(
                cost: gross_amount(cost[:cost], taxation_options_for(shipping_method)),
                tax_rate: first_tax_rate_for(shipping_method.tax_category),
                courier_id: cost[:courier_id]
              )
            else
              shipping_method.shipping_rates.new(
                cost: gross_amount(cost, taxation_options_for(shipping_method)),
                tax_rate: first_tax_rate_for(shipping_method.tax_category),
                courier_id: nil
              )
            end
          end.compact
        end
      end
    end
  end
end

::Spree::Stock::Estimator.prepend ::SpreeShippo::Spree::Stock::EstimatorDecorator
