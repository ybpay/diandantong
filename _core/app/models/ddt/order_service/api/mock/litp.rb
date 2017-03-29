module Ddt
  module OrderService
    module Api
      module Mock
        class Litp
          def self.query(params={})
            page = params[:page].try(:to_i) || 1
            per_page = params[:per_page].try(:to_i) || 20
            rps = params.except(:page, :per_page)
            total = Model::LineItemTracePoint.ransack(rps).result.count
            if page.present?
              litps = Model::LineItemTracePoint.includes(:order).ransack(rps).result.distinct.paginate(page: page, per_page: per_page)
            else
              litps = Model::LineItemTracePoint.includes(:order).ransack(rps).result
            end
            {
              current_page: page,
              per_page: per_page,
              is_first_page: page == 1,
              is_last_page: litps.size < per_page,
              total_count: total,
              total_pages: (total * 1.0 / per_page).ceil,
              sort: rps[:s],
              count: litps.count,
              content: litps.map{|litp| litp_to_hash(litp) }
            }
          end

          def self.count(params={})
            Model::LineItemTracePoint.ransack(params).result.count
          end

          def self.get(id)
            litp = Model::LineItemTracePoint.find(id)
            litp_to_hash(litp)
          end

          def self.update(id, body={})
            litp = single_update(id, body)
            litp_to_hash(litp.reload) if litp.present?
          end


          private
          def self.single_update(id, body={})
            litp = Model::LineItemTracePoint.find(id)
            litp.update(body.merge(updated_at: Time.now))
            litp
          end

          def self.litp_to_hash(litp)
            select = Model::LineItemTracePoint.column_names
            hash = litp.as_json(only: select)
            order = litp.order
            hash[:order] = order.as_json(only: [:number, :type, :state, :created_at, :table_id, :table_name, :table_zone_name, :note]).symbolize_keys
            hash.symbolize_keys
          end
        end
      end
    end
  end
end