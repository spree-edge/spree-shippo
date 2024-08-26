module SpreeShippo
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_shippo'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_shippo.environment', before: :load_config_initializers do |_app|
      SpreeShippo::Config = SpreeShippo::Configuration.new
    end

    config.after_initialize do
      Rails.application.config.spree.calculators.shipping_methods.concat [
        Spree::Calculator::Shipping::UspsFirstClassPackageInternationalServiceCalculator,
        Spree::Calculator::Shipping::UspsPriorityMailCalculator,
        Spree::Calculator::Shipping::UspsPriorityMailExpressCalculator,
        Spree::Calculator::Shipping::UspsPriorityMailExpressInternationalCalculator,
        Spree::Calculator::Shipping::UspsPriorityMailInternationalCalculator,
      ]
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
