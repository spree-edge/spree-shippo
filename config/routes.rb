Spree::Core::Engine.add_routes do
  get '/admin/orders/:id/label_generator' => 'admin/label_generator#index', as: 'admin_orders_label_generator'
  get '/admin/orders/:id/label_generator/:line_item_id/ship_label' => 'admin/label_generator#generate_shipping_label', as: 'admin_orders_label_generator_ship_label'
  get '/admin/orders/:id/label_generator/:line_item_id/return_label' => 'admin/label_generator#generate_return_label', as: 'admin_orders_label_generator_return_label'
  get '/admin/orders/:id/label_generator/:line_item_id/itemdetail' => 'admin/label_generator#get_item_details', as: 'admin_orders_label_generator_item_detail'
  get '/orders/:id/tracking' => 'shipment_tracking#index', as: 'user_orders_shipment_tracking'
end
