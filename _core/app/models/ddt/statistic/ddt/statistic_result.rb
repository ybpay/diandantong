module Ddt
  class StatisticResult
    include ActionView::Helpers::TagHelper
    attr_accessor :output_buffer, :statistic, :title, :body, :foot, :is_custom_head, :custom_thead, :link_template, :link_hash

    def initialize(statistic)
      @statistic = statistic
      @title = statistic.title
      @body = statistic.body
      @foot = statistic.foot
      @is_custom_head = statistic.custom_thead?
      @custom_thead = statistic.custom_thead
      @link_template = statistic.link_template
      @link_hash = statistic.link_hash
    end

    def to_html
      big_table = body.size > 0 && body[0].size > 17 ? true : false
      if big_table
        content_tag :div, table, class: 'big-table'
      else
        table
      end
    end

    def to_wechat_html
      wechat_thead + wechat_tbody
    end

    def to_csv(file = StringIO.new)
      csv = CSV.new(file)
      csv << title
      body.each do |arr|
        csv << arr
      end
      if foot.present?
        foot.each do |row|
          csv << row
        end
      end
      file
    end

    def to_xls(file = StringIO.new)
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new(file)
      sheet = book.create_worksheet
      sheet.row(0).concat title
      body.each_with_index do |row, index|
        sheet.row(index + 1).concat(row)
      end
      n = body.size + 1
      if foot.present?
        foot.each_with_index do |row, index|
          sheet.row(index +n).concat(row)
        end
      end
      book.write file
      file
    end

    def to_hash
      content = []
      body.each do |row|
        content << row
      end
      content << foot if foot.present?
      {
        body: content
      }
    end

    private

    def wechat_thead
      content_tag :div, class: 'table-head' do
        content_tag :table, class: 'table' do
          colgroup = content_tag :colgroup do
            content_tag(:col)
          end
          colgroup + thead
        end
      end
    end

    def wechat_tbody
      content_tag :div, class: 'table-body' do
        content_tag :table, class: 'table'  do
          colgroup = content_tag :colgroup do
            content_tag(:col)
          end
          colgroup + tbody
        end
      end
    end

    def table
      table_classes = %W[statistic-table]
      if statistic.class.info[:sortable]
        table_classes << 'sortable-table'
        table_classes << 'tablesorter'
      end
      content_tag :table, class: table_classes  do
        thead + tbody + tfoot
      end
    end

    def thead
      content_tag :thead do
        if is_custom_head
          custom_thead.map do |tr|
            content_tag :tr do
              tr.map do |th|
                content_tag(:th, th[:name].html_safe, (th[:th_attrs] || {}) )
              end.join.html_safe
            end
          end.join.html_safe
        else
          content_tag :tr do
            title.map do |name|
              content_tag(:th, name)
            end.join.html_safe
          end
        end
      end
    end

    def tbody
      content_tag :tbody do
        if body.size == 0
          content_tag :tr do
            content_tag :td, colspan: 100 do
              content_tag(:div, '目前找不到记录', class: 'alert alert-info').html_safe
            end
          end
        else
          body.map do |row|
            content_tag :tr do
              html = ""
              row.each_with_index do |value, index|
                if link_template[index].present?
                  if value.blank?
                    html << content_tag(:td, value)
                  else
                    html << content_tag(:td, (link_template[index] % [link_hash[value], value]).html_safe)
                  end
                else
                  html << content_tag(:td, value)
                end
              end
              html.html_safe
            end
          end.join.html_safe
        end
      end
    end

    def tfoot
      return '' if foot.blank?
      content_tag :tfoot, class: 'alert alert-warning' do
        foot.map do |row|
          content_tag :tr do
            row.map do |value|
              content_tag(:td, value)
            end.join.html_safe
          end
        end.join.html_safe
      end
    end



  end
end
