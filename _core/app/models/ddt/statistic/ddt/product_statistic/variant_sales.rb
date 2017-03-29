module Ddt
  module ProductStatistic
    module VariantSales
      extend ActiveSupport::Concern

      def variant_sales
        attrs = {is_async: false, group_by: :sku, shop: shop, branch_id: branch_id, start_time: start_time, end_time: end_time, time_interval_id: time_interval_id}
        attrs[:order_id] = order_id if order_id.present?
        attrs[:filters] = skus if skus.present?

        step = 0
        [
          Ddt::ProductStatistic::VariantSummary,
          Ddt::ProductStatistic::VariantPackageSummary,
          Ddt::ProductStatistic::ComboProduct,
        ].map do |klass|
          step += 1
          sub_stat = klass.new(attrs)
          if @cache_record.present?
            sub_stat.on_split_query_progress = ->(progress){
              @cache_record.progress = (100 * (step-1) + progress) / 3
              @cache_record.cost_time = Time.now - @async_statistics_start_at
              @cache_record.save
            }
          end
          sub_stat.to_variant_sales
        end
      end
    end
  end
end
