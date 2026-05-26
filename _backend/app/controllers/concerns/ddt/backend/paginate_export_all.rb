module Ddt
  module Backend
    module PaginateExportAll
      extend ActiveSupport::Concern

      included do
        before_action :set_record_num, only: [:index, :get_export_list, :anti_settlements]
        before_action :set_export_all_path, only: [:index, :get_export_list, :anti_settlements]
        before_action :set_per_page, only: [:export_all]
      end

      def get_export_list
        @page_num = page_num
        respond_to do |format|
          format.js do
            render "ddt/backend/common/paginate_export_all/get_export_list"
          end
        end
      end

      private

        def set_record_num
          @record_num = search.result(distinct: true).count
        end

        def set_per_page
          set_record_num
          page = params[:page].try(:to_i)
          @page_invalid = false
          @page_invalid = true if page && (page <= 0 || page > page_num)
          params[:per_page] = per_page
          if @page_invalid
            render plain: "操作非法"
            return
          end
        end

        def page_num
          @record_num/per_page + (@record_num % per_page == 0 ? 0 : 1)
        end

        def per_page
          10
        end
    end
  end
end
