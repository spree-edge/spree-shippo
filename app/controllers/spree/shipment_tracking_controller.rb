module Spree
  class ShipmentTrackingController < Spree::StoreController
    before_action :load_order_and_shipments, only: :index

    def index ; end

    private

    def load_order_and_shipments
      @order = Spree::Order.find_by(number: params[:id])
      @shipments = @order&.shipments
    end
  end
end
