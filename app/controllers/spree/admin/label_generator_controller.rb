module Spree
  module Admin
    class LabelGeneratorController < Spree::Admin::BaseController
      skip_before_action :authorize_admin, only: [:index]
      before_action :load_order

      def index
        authorize! :index, :label_generator
      end

      def generate_shipping_label
        handle_label_generation(:get_user_shipping_label)
      end

      def generate_return_label
        handle_label_generation(:get_user_return_label)
      end

      def get_item_details
        line_item = find_line_item
        pdf_path = generate_item_details_pdf(line_item)

        send_file pdf_path,
                  filename: pdf_filename(line_item),
                  type: "application/pdf",
                  disposition: "attachment"
      end

      private

      def load_order
        @order = Spree::Order.find_by_number(params[:order_id] || params[:id])
        @line_items = @order.line_items
      end

      def find_line_item
        Spree::LineItem.find_by_id(params[:line_item_id])
      end

      def handle_label_generation(label_method)
        line_item = find_line_item
        result = @order.public_send(label_method, line_item)

        flash[:success] = result['messages']&.first&.text if result != true
        redirect_to label_generator_admin_order_path(@order.number)
      end

      def generate_item_details_pdf(line_item)
        rendered_html = render_item_details_template(line_item)
        pdf_content = WickedPdf.new.pdf_from_string(rendered_html)
        save_pdf_to_file(pdf_content, line_item.id)
      end

      def render_item_details_template(line_item)
        ApplicationController.new.render_to_string(
          template: "spree/admin/label_generator/item_detail",
          locals: { line_item: line_item },
          format: :html,
          layout: "spree/layouts/pdf"
        )
      end

      def save_pdf_to_file(pdf_content, line_item_id)
        pdf_path = Rails.root.join('tmp', "item_details_\#{line_item_id}.pdf")
        File.write(pdf_path, pdf_content)
        pdf_path
      end

      def pdf_filename(line_item)
        "item_details_\#{line_item.id}.pdf"
      end
    end
  end
end
