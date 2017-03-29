module Ddt
  module OrderService
    module Api
      class Order
        include OrderService::Api::Base
        def self.place(body={}, options={})
          # "Ddt::FastfoodOrder".demodulize.underscore => fastfood_order
          type = body[:type].demodulize.underscore
          service_post("/#{type}s/place", change_options(options), body)
        end

        def self.get(id, options={})
          service_get("/orders/#{id}", change_options(options))
        end

        def self.query(params={}, options={})
          new_params = params.merge({
              _format: :ransack,
              _page: params[:page],
              _size: params[:per_page],
            }).except(:page, :per_page)
          service_get("/orders", new_params.merge(change_options(options)))
        end

        def self.count(params={})
          service_get("/orders/count", params.merge(_format: :ransack)).try(:to_i)
        end

        def self.update(id, body={}, options={})
          service_put("/orders/#{id}", change_options(options), body)
        end

        def self.batch_update(body={}, options={})
          service_put("/orders/batch_update", change_options(options), body)
        end

        def self.erase_data(branch_id, from, to)
          # TODO 订单系统需添加该api
          service_post("/orders/erase_data", {branch_id: branch_id, from: from, to: to})
        end

        def self.rollback_erase(branch_id, from, to)
          # TODO 订单系统需添加该api
          service_post("/orders/rollback_erase", {branch_id: branch_id, from: from, to: to})
        end

        mock_for :place, :get, :query, :count, :update, :batch_update, :erase_data, :rollback_erase

        private
        def self.change_options(options={})
          includes_option = options.fetch(:includes, [:line_items, :adjustments, :pay_items, :order_change_logs, :form_contents])
          {
            _select:                       options.fetch(:select, []).map{|key| key.to_s.camelize(:lower) }.join(","),
            _includes:                     includes_option.map{|key| key.to_s.camelize(:lower) }.join(","),
            _line_item_select:             options.fetch(:line_item_select,[]).map{|key| key.to_s.camelize(:lower) }.join(","),
            _adjustment_select:            options.fetch(:adjustment_select,[]).map{|key| key.to_s.camelize(:lower) }.join(","),
            _pay_item_select:              options.fetch(:pay_item_select,[]).map{|key| key.to_s.camelize(:lower) }.join(","),
            _order_change_log_select:      options.fetch(:order_change_log_select,[]).map{|key| key.to_s.camelize(:lower) }.join(","),
            _line_item_trace_point_select: options.fetch(:line_item_trace_point_select,[]).map{|key| key.to_s.camelize(:lower) }.join(","),
            _form_content_select:          options.fetch(:form_content_select,[]).map{|key| key.to_s.camelize(:lower) }.join(","),
          }
        end
      end
    end
  end
end
