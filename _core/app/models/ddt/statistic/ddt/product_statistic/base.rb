#encoding: utf-8
module Ddt
  module ProductStatistic
    class Base < ::Ddt::StatisticBase
      include Ddt::CacheModel
      cache_model 'Ddt::Variant', with_deleted: true
      cache_model 'Ddt::VariantPackage', with_deleted: true
      attr_accessor :branch, :branch_id, :start_time, :end_time, :table_id, :sort
      hash_attrs({
          门店: :branch_id,
          开始时间: :start_time,
          结束时间: :end_time,
          排序: :sort
     })

      def initialize(options)
        super
        @branch_id = options[:branch_id]
        if options[:branch_id].present? and options[:branch_id].to_i > 0
          @branch = Ddt::Branch.find(options[:branch_id])
        elsif options[:branch_id].to_i == ALL_BRANCH
          @branch_id = options[:branch_id]
        else
          @branch_id = nil
        end
        @start_time, @end_time = options[:start_time], options[:end_time]
        @table_id = options[:table_id] if options[:table_id]
        @sort = options[:sort].try(:to_sym)
      end

      def sku(itemable_type, itemable_id)
        case itemable_type
        when 'Ddt::Variant'
          get_variant(itemable_id).try(:sku) || ''
        when 'Ddt::VariantPackage'
          get_variant_package(itemable_id).try(:sku) || ''
        else
          ''
        end
      end

      def unit_name(itemable_type, itemable_id)
        case itemable_type
        when 'Ddt::Variant'
          get_variant(itemable_id).try(:unit_name) || ''
        when 'Ddt::VariantPackage'
          get_variant_package(itemable_id).try(:unit_name) || ''
        else
          ''
        end
      end

    end
  end
end
