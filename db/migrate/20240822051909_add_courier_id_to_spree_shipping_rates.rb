# frozen_string_literal: true

class AddCourierIdToSpreeShippingRates < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:spree_shipping_rates, :courier_id)
      add_column :spree_shipping_rates, :courier_id, :string
    end
  end
end
