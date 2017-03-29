module Ddt
  class SaleDataUploaderSetting < Ddt::Base
    include BelongsToBranch

    def upload_base
      variants = self.branch.variants.pluck(:id, :sku, :cache_name)
      combos = self.branch.combos.pluck(:id, :sku, :name)
      pay_methods = self.shop.pay_methods.pluck(:id, :code, :name)
      result = Api.send_post("/branches/#{self.branch_id}/upload_base", {
          variants: variants.map{|v| { id: v[0], sku: v[1], name: v[2]}},
          combos: combos.map{|v| { id: v[0], sku: v[1], name: v[2]}},
          pay_methods: pay_methods.map{|v| { id: v[0], code: v[1], name: v[2]}},
        })
      result[:status] == "ok"
    end

    def self.upload_orders(branch_id, start_time, end_time)
      SaleDataUploaderSetting.upload_shifts(branch_id, start_time, end_time)
      branch = Branch.find(branch_id)
      orders = branch.orders.paid.where(type_in: ["Ddt::DeliveryOrder", "Ddt::EatInHallOrder", "Ddt::FastfoodOrder"], paid_at: start_time..end_time)
      orders.each do |order|
        self.upload_order(branch, order)
      end
    end

    def self.reupload_orders(branch_id, start_time, end_time)
      SaleDataUploaderSetting.upload_shifts(branch_id, start_time, end_time)
      branch = Branch.find(branch_id)
      orders = branch.orders.paid.where(type_in: ["Ddt::DeliveryOrder", "Ddt::EatInHallOrder", "Ddt::FastfoodOrder"], paid_at: start_time..end_time)
      orders.each do |order|
        self.reupload_order(branch, order)
      end
    end

    def self.query_orders(branch_id, start_time, end_time)
      branch = Branch.find(branch_id)
      orders = branch.orders.paid.includes_none.where(type_in: ["Ddt::DeliveryOrder", "Ddt::EatInHallOrder", "Ddt::FastfoodOrder"], paid_at: start_time..end_time)
      order_ids = orders.map(&:id)
      result = Api.send_post("/branches/#{branch.id}/query_order", {
        order_ids: order_ids
      })
    end

    def self.upload_shifts(branch_id, start_time, end_time)
      branch = Branch.find(branch_id)
      shifts = branch.shifts.where(created_at: start_time..end_time)
      shifts.each do |shift|
        result = Api.send_post("/branches/#{branch.id}/upload_shift", {
          shift: {
            id: shift.id,
            opened_at: shift.created_at,
            closed_at: shift.closed_at,
            order_count: shift.total_eat_in_hall_order_count
          }
        })
        result[:status] == "ok"
      end
    end

    def self.upload_order(branch, order)
      if order.present?
        hash = get_data_for_upload_order(order)
        result = Api.send_post("/branches/#{branch.id}/upload_order", {
          order: hash
        })
        result[:status] == "ok"
      end
    end

    def self.reupload_order(branch, order)
      if order.present?
        hash = get_data_for_upload_order(order)
        result = Api.send_post("/branches/#{branch.id}/reupload_order", {
          order: hash
        })
        result[:status] == "ok"
      end
    end

    def self.get_data_for_upload_order(order)
      {
        id: order.id,
        number: order.number,
        placed_at: order.placed_at,
        paid_at: order.paid_at,
        settle_account_id: order.settle_account_id,
        item_total: order.item_total,
        total: order.total,
        moling_amount: order.moling_amount,
        line_items: order.line_items.active.map{ |line_item|
          {
            id:            line_item.id,
            itemable_type: line_item.itemable_type,
            itemable_id:   line_item.itemable_id,
            variant_id:    (line_item.is_variant? ? line_item.itemable_id : (line_item.is_variant_package? ? line_item.itemable.variant_id : nil)),
            combo_id:      (line_item.is_combo_package? ? line_item.itemable.combo_id : nil),
            itemable_name: line_item.itemable_name,
            product_name:  line_item.product_name,
            quantity:      line_item.quantity,
            subtotal:      line_item.subtotal,
          }
        },
        pay_items: order.pay_items.map{ |pay_item|
          {
            id:              pay_item.id,
            pay_method_id:   pay_item.pay_method_id,
            pay_method_name: pay_item.pay_method_name,
            pay_method_percent_of_actual: pay_item.pay_method_percent_of_actual,
            not_actual_amount: pay_item.not_actual_amount,
            amount:          pay_item.amount,
          }
        },
        adjustments: order.adjustments.active.map{|adjustment|
          {
            id:       adjustment.id,
            reason:   adjustment.reason,
            label:    adjustment.label,
            amount:   adjustment.amount,
          }
        }
      }
    end

    class Api
      def self.send_post(url, params)
        config = Ddt::SaleDataUploaderConfig
        server = config["server"]
        api_key = config["api_key"]
        access_id = config["access_id"]
        uri = URI.parse("#{server}#{url}.json")
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 10
        http.read_timeout = 10
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(data: params.to_json)
        request = ApiAuth.sign!(request, access_id, api_key)
        puts ApiAuth.authentic?(request, api_key)
        response = http.request(request)
        Rails.logger.info response.body
        result = JSON.parse(response.body)
        if result.is_a? Array
          result.map(&:symbolize_keys)
        else
          result.symbolize_keys
        end
      end
    end
  end
end
