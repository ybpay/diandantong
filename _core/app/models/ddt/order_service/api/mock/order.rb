module Ddt
  module OrderService
    module Api
      module Mock
        class Order
          def self.place(body={}, options={})
            ActiveRecord::Base.transaction do
              # need set created_at updated_at
              line_item_attrs = body.delete(:line_items)
              adjustment_attrs = body.delete(:adjustments)
              pay_item_attrs = body.delete(:pay_items)
              order_change_log_attrs = body.delete(:order_change_logs)
              form_content_attrs = body.delete(:form_contents)
              order = Model::Order.create(body)
              order_change_logs = order_change_log_attrs.map { |attrs| Model::OrderChangeLog.new(attrs.merge(order_id: order.id, shop_id: order.shop_id, branch_id: order.branch_id)) }
              Model::OrderChangeLog.import(order_change_logs, validate: false)
              # set line_item.order_change_log_id
              order_change_log = order.order_change_logs.last
              litp_attrs = line_item_attrs.map{|attrs| attrs.delete(:line_item_trace_points)}
              line_items = line_item_attrs.map { |attrs| Model::LineItem.new(attrs.merge(order_id: order.id, shop_id: order.shop_id, branch_id: order.branch_id, order_change_log_id: order_change_log.id)) }
              Model::LineItem.import(line_items, validate: false)
              item_adjustments_attrs = adjustment_attrs.map{|attrs| attrs.delete(:item_adjustments)}
              adjustments = adjustment_attrs.map { |attrs| adjustment = Model::Adjustment.new(attrs.merge(order_id: order.id, shop_id: order.shop_id, branch_id: order.branch_id))}
              Model::Adjustment.import(adjustments, validate: false)
              pay_items = pay_item_attrs.map { |attrs| Model::PayItem.new(attrs.merge(order_id: order.id, shop_id: order.shop_id, branch_id: order.branch_id)) }
              Model::PayItem.import(pay_items, validate: false)
              form_contents = form_content_attrs.map { |attrs| Model::FormContent.new(attrs.merge(order_id: order.id)) }
              Model::FormContent.import(form_contents, validate: false)
              # create line_item_trace_point
              litps = []
              order.line_items.each_with_index do |line_item, index|
                if litp_attrs[index].present?
                  litps += litp_attrs[index].map do |litp_attr|
                    Model::LineItemTracePoint.new(litp_attr.merge(
                        order_id: order.id,
                        shop_id: order.shop_id,
                        branch_id: order.branch_id,
                        line_item_id: line_item.id,
                        order_change_log_id: line_item.order_change_log_id,
                        note: line_item.note,
                        state: "pending"
                      ))
                  end
                end
              end
              Model::LineItemTracePoint.import(litps, validate: false)
              # create item_adjustments
              all_item_adjustments = []
              line_item_ids = order.line_items.pluck(:id)
              adjustment_ids = order.adjustments.pluck(:id)
              adjustment_ids.each_with_index do |adjustment_id, index|
                if item_adjustments_attrs[index].present?
                  all_item_adjustments += item_adjustments_attrs[index].map do |item_adjustment_attr|
                    line_item_index = item_adjustment_attr.delete(:line_item_index)
                    Model::Adjustment.new(item_adjustment_attr.merge({
                        order_id: order.id,
                        shop_id: order.shop_id,
                        branch_id: order.branch_id,
                        parent_id: adjustment_id,
                        line_item_id: line_item_ids[line_item_index]
                      }))
                  end
                end
              end
              Model::Adjustment.import(all_item_adjustments, validate: false)
              order_to_hash(order.reload, options)
            end
          end

          def self.get(id, options={})
            includes_option = options.fetch(:includes, [:line_items, :adjustments, :pay_items, :order_change_logs, :form_contents])
            if includes_option.present?
              order = Model::Order.includes(*includes_option).find(id)
            else
              order = Model::Order.find(id)
            end
            order_to_hash(order, options)
          end

          def self.count(params={})
            Model::Order.ransack(params).result.count
          end

          def self.query(params={}, options={})
            page = params[:page].try(:to_i) || 1
            per_page = params[:per_page].try(:to_i) || 20
            rps = params.except(:page, :per_page)
            total = Model::Order.ransack(rps).result.count
            includes_option = options.fetch(:includes, [:line_items, :adjustments, :pay_items, :order_change_logs, :form_contents])
            if page.present?
              orders = Model::Order.ransack(rps).result.distinct.paginate(page: page, per_page: per_page)
            else
              orders = Model::Order.ransack(rps).result
            end
            if includes_option.present?
              orders = orders.includes(*includes_option)
            end
            {
              current_page: page,
              per_page: per_page,
              is_first_page: page == 1,
              is_last_page: orders.size < per_page,
              total_count: total,
              total_pages: (total * 1.0 / per_page).ceil,
              sort: rps[:s],
              count: orders.count,
              content: orders.map{|order| order_to_hash(order, options) }
            }
          end

          def self.update(id, body={}, options={})
            order = single_update(id, body)
            order_to_hash(order.reload, options) if order.present?
          end

          def self.batch_update(body={}, options={})
            body[:orders].each do |body_item|
              id = body_item.delete(:id)
              order = single_update(id, body_item)
              raise unless order.present?
            end
            true
          end

          def self.erase_data(branch_id, from, to)
            Ddt::Eraser.perform_order_data(branch_id, from, to)
          end

          def self.rollback_erase(branch_id, from, to)
            Ddt::Eraser.rollback_order_data(branch_id, from, to)
          end

          concerning :PrivateMethod do
            included do
              def self.single_update(id, body={})
                # need set created_at updated_at deleted_at
                ActiveRecord::Base.transaction do
                  relations = [:line_items, :adjustments, :pay_items, :order_change_logs, :form_contents, :line_item_trace_points]
                  order = Model::Order.where(id: id).lock(true).first
                  pre_updated_at = body.delete(:pre_updated_at)
                  # 乐观锁
                  if order.updated_at.to_datetime.strftime("%Q") != pre_updated_at.to_datetime.strftime("%Q")
                    raise Api::UpdateLockError.new("order_id #{order.id} " + order.updated_at.to_datetime.strftime("%Q") + " != " + pre_updated_at.to_datetime.strftime("%Q"))
                  else
                    order.update(body.except(*relations).merge(updated_at: Time.now))
                    [:pay_items, :order_change_logs, :form_contents, :line_item_trace_points].each do |relation|
                      if body[relation].present?
                        body[relation].each do |hash|
                          # 删除标志 _destroy
                          _destroy = hash.delete(:destroy)
                          if hash[:id].present?
                            item = Model.const_get(relation.to_s.classify).find(hash[:id])
                            if _destroy
                              item.destroy
                            else
                              item.update(hash.except(:id))
                            end
                          else
                            if relation == :form_contents
                              order.send(relation).create(hash)
                            else
                              order.send(relation).create(hash.merge(shop_id: order.shop_id, branch_id: order.branch_id))
                            end
                          end
                        end
                      end
                    end
                    if body[:line_items].present?
                      litp_attrs = body[:line_items].select{|attrs| attrs[:id].blank? }.map{|attrs| attrs.delete(:line_item_trace_points)}
                      new_line_items = []
                      body[:line_items].each do |hash|
                        # 删除标志 _destroy
                        _destroy = hash.delete(:destroy)
                        if hash[:id].present?
                          item = Model::LineItem.find(hash[:id])
                          if _destroy
                            item.destroy
                          else
                            item.update(hash.except(:id, :line_item_trace_points))
                          end
                        else
                          change_log = order.order_change_logs.last
                          new_line_items << order.line_items.create(hash.merge(order_change_log_id: change_log.id, shop_id: order.shop_id, branch_id: order.branch_id))
                        end
                      end
                      # create line_item_trace_point
                      litps = []
                      new_line_items.each_with_index do |line_item, index|
                        if litp_attrs[index].present?
                          litps += litp_attrs[index].map do |litp_attr|
                            Model::LineItemTracePoint.new(litp_attr.merge(
                                order_id: order.id,
                                shop_id: order.shop_id,
                                branch_id: order.branch_id,
                                line_item_id: line_item.id,
                                order_change_log_id: line_item.order_change_log_id,
                                note: line_item.note,
                                state: "pending"
                              ))
                          end
                        end
                      end
                      Model::LineItemTracePoint.import(litps, validate: false)
                    end
                    if body[:adjustments].present?
                      item_adjustments_attrs = body[:adjustments].map{|attrs| attrs.delete(:item_adjustments)}
                      changed_adjustments = []
                      body[:adjustments].each do |hash|
                        # 删除标志 _destroy
                        _destroy = hash.delete(:destroy)
                        if hash[:id].present?
                          item = Model::Adjustment.find(hash[:id])
                          if _destroy
                            item.destroy
                          else
                            item.update(hash.except(:id))
                          end
                          changed_adjustments << item
                        else
                          new_adjustment = order.adjustments.create(hash.merge(shop_id: order.shop_id, branch_id: order.branch_id))
                          changed_adjustments << new_adjustment
                        end
                      end
                      line_item_ids = order.line_items.pluck(:id)
                      changed_adjustments.each_with_index do |parent, index|
                        if item_adjustments_attrs[index].present?
                          item_adjustments_attrs[index].each do |hash|
                            _destroy = hash.delete(:destroy)
                            if hash[:id].present?
                              item = Model::Adjustment.find(hash[:id])
                              if _destroy
                                item.destroy
                              else
                                item.update(hash.except(:id, :line_item_index))
                              end
                            else
                              line_item_id = hash.delete(:line_item_id)
                              line_item_index = hash.delete(:line_item_index)
                              line_item_id ||= line_item_ids[line_item_index] if line_item_index.present?
                              order.adjustments.create(hash.merge(
                                shop_id: order.shop_id,
                                branch_id: order.branch_id,
                                parent_id: parent.id,
                                line_item_id: line_item_id
                              ))
                            end
                          end
                        end
                      end
                    end
                    order
                  end
                end
              end

              def self.order_to_hash(order, options={})
                order_select            = options.fetch(:select,                   Model::Order.column_names.reject{|c| c == 'old_number'})
                line_item_select        = options.fetch(:line_item_select,         Model::LineItem.column_names)
                adjustment_select       = options.fetch(:adjustment_select,        Model::Adjustment.column_names)
                pay_item_select         = options.fetch(:pay_item_select,          Model::PayItem.column_names)
                order_change_log_select = options.fetch(:order_change_log_select,  Model::OrderChangeLog.column_names)
                form_content_select     = options.fetch(:form_content_select,      Model::FormContent.column_names)
                litp_select             = options.fetch(:line_item_trace_point_select,  Model::LineItemTracePoint.column_names)
                includes                = options.fetch(:includes, [:line_items, :adjustments, :pay_items, :order_change_logs, :form_contents])
                hash = order.as_json(only: order_select)
                hash[:line_items]        = order.line_items.map{|line_item| line_item.as_json(only: line_item_select).symbolize_keys} if includes.include?(:line_items)
                if includes.include?(:adjustments)
                  hash[:adjustments] = order.adjustments.select{|a| a.parent_id == nil }.map do |adjustment|
                    subs = order.adjustments.select{|a| a.parent_id == adjustment.id }
                    adjustment.as_json(only: adjustment_select).symbolize_keys.merge({
                      item_adjustments: subs.map{|a| a.as_json(only: (adjustment_select + [:line_item_id, :parent_id]).uniq).symbolize_keys }
                    })
                  end
                end
                hash[:pay_items]         = order.pay_items.map{|pay_item| pay_item.as_json(only: pay_item_select).symbolize_keys} if includes.include?(:pay_items)
                hash[:order_change_logs] = order.order_change_logs.map{|log| log.as_json(only: order_change_log_select).symbolize_keys} if includes.include?(:order_change_logs)
                hash[:form_contents]     = order.form_contents.map{|log| log.as_json(only: form_content_select).symbolize_keys} if includes.include?(:form_contents)
                hash[:line_item_trace_points] = order.line_item_trace_points.map{|litp| litp.as_json(only: litp_select).symbolize_keys} if includes.include?(:line_item_trace_points)
                hash.symbolize_keys
              end
            end
          end
        end
      end
    end
  end
end
