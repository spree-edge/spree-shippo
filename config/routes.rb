Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :shippo_settings, only: :[] do
      collection do
        get "edit"
        patch "update"
      end
    end

    resources :orders, only: [] do
      member do
        get 'label_generator', to: 'label_generator#index', as: :label_generator
      end
  
      resources :label_generator, only: [], param: :line_item_id do
        member do
          get 'ship_label', to: 'label_generator#generate_shipping_label', as: :ship_label
          get 'return_label', to: 'label_generator#generate_return_label', as: :return_label
          get 'itemdetail', to: 'label_generator#get_item_details', as: :item_detail
        end
      end
    end
  end

  resources :orders, only: [] do
    member do
      get 'tracking', to: 'shipment_tracking#index', as: :shipment_tracking
    end
  end
end
