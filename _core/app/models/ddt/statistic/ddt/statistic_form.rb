module Ddt
  class StatisticForm

    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormOptionsHelper
    attr_accessor :statistic_name, :statistic, :path, :filters, :output_buffer

    # require_attr: name, type, placeholder/prompt
    # type: [date, datetime, time, string, integer, boolean, ddselect2, collection]
    # [
    #   { name: 'branch_ids', type: 'ddselect2', data: {}},
    #   { name: 'pay_method', type: 'collection', collection: [], prompt: '支付方式'},
    #   { name: 'start_time', type: 'date', placeholder: '开始时间'},
    #   { name: 'end_time', type: 'date', placeholder: '结束时间'}
    #   { name: 'time_interval', type: 'collection', collection: [], prompt: '时段'}
    # ]

    def initialize(statistic)
      @statistic = statistic
      @statistic_name = statistic.statistic_name
      @path = statistic.request_path.gsub(/\.html|\.csv|\.xls/, '')
      @filters = statistic.filters
    end

    def to_html
      content_tag :div, :class=>"form-group" do
        form_for statistic_name, url: path, method: :get, html: { class: 'form-inline', role: 'form'}, builder: SimpleForm::FormBuilder do|f|
          comps = filters.map do |filter|
            filter[:placeholder] = '' if filter[:placeholder].nil?
            case filter[:type].to_sym
            when :ddselect2
              f.input_field filter[:name], data: filter[:data], class: 'ddb-select2 col-lg-2 form-control', placeholder: filter[:placeholder], value: statistic.send(filter[:name])
            when :collection
              f.input_field filter[:name], collection: filter[:collection], prompt: filter[:prompt], include_blank: filter[:include_blank], selected: statistic.send(filter[:name].to_sym),class: 'form-control'
            else
              # date, datetime, time, string, boolean, integer
              f.input_field filter[:name], as: filter[:type], placeholder: filter[:placeholder], value: statistic.send(filter[:name]), class: 'form-control'
            end
          end
          comps << (f.input_field :page, as: 'integer', value: (statistic.page.blank? ? 1 : statistic.page) , placeholder: '', style: 'display: none;')
          comps << (f.submit "搜索", class: 'btn btn-sm btn-success', onClick: "$(this).closest('form').attr('action', '#{path + ".html"}')")
          if @statistic.pr_type == 'result'
            comps << (f.submit "导出csv表格", class: 'btn btn-sm btn-info', onClick: "$(this).closest('form').attr('action', '#{ path + ".csv" }')")
            comps << (f.submit "导出xls表格", class: 'btn btn-sm btn-warning', onClick: "$(this).closest('form').attr('action', '#{ path + ".xls"}')")
          end
          (comps.join("&nbsp;&nbsp;") + "<br />").html_safe
        end
      end
    end

  end
end
