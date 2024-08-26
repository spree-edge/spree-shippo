# frozen_string_literal: true

class AddItemBoxToSpreeLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column_if_not_exists(:item_box_shipping_label, :frame_box_shipping_label)
    add_column_if_not_exists(:item_box_return_label, :frame_box_return_label)
  end

  private

  def add_column_if_not_exists(item_column, frame_column)
    unless column_exists?(:spree_line_items, item_column) || column_exists?(:spree_line_items, frame_column)
      add_column :spree_line_items, item_column, :string
    end
  end
end
