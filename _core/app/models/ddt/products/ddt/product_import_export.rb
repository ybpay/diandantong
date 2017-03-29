# encoding:utf-8
module Ddt
  module ProductImportExport
    extend ActiveSupport::Concern
    included do
      def categories_text(options = {})
        options.reverse_merge!(sep: ",")
        self.categories.map(&:name_with_parent).join(options[:sep])
      end

      def option_types_text(options = {})
        options.reverse_merge!(sep: ",")
        self.option_types.map(&:name).join(options[:sep])
      end

      def variants_text(options = {})
        options.reverse_merge!(sep: ",")
        self.variants.map do |variant|
          variant.serialized_text(sep: "*")
        end.join(options[:sep])
      end

      def tags_text(options = {})
        options.reverse_merge!(sep: ",")
        self.tags.map(&:name).join(options[:sep])
      end

    end

    module ClassMethods
      FILE_HEADER = %W[
        编号
        名称
        SKU
        价格
        会员价格
        库存
        单位名称
        描述
        商品分类
        商品标签
        规格类型
        其他型号
        允许修改重量
      ]
      def to_csv(options = {})
        CSV.generate(options) do |csv|
          csv << FILE_HEADER
          all.each do |product|
            str = product_row_info(product)
            if str[12]
              str[12] = "是"
              csv << str
            else
              str[12] = ""
              csv << str
            end
          end
        end
      end

      def to_xls
        spreadsheet = StringIO.new
        # tmp_file_path = Rails.root.join('tmp', "products_#{DateTime.now.to_i}.xls")
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet
        sheet.row(0).concat FILE_HEADER
        # debugger
        all.each_with_index do |product, index|
          str = product_row_info(product)
          if str[12]
            str[12] = "是"
            sheet.row(index + 1).concat(str)
          else
            str[12] = ""
            sheet.row(index + 1).concat(str)
          end
        end
        book.write spreadsheet
        spreadsheet.string
      end

      def update_and_create_from_file(branch, file)
        rows = get_rows_from_file(file)
        error_lines = []
        rows.each do |row|
          result, error = save_product_from_row(branch, {
            id:                row[0],
            name:              row[1],
            sku:               row[2],
            price:             row[3],
            vip_price:         row[4],
            stock_quantity:    row[5],
            unit_name:         row[6],
            description:       row[7] || '<p></p>',
            categories_text:   row[8],
            tags_text:         row[9],
            option_types_text: row[10],
            variants_text:     row[11],
            by_weight:       row[12]
          })
          error_lines << row.push(error) unless result
        end

        branch.last_import_product_error.try(:destroy)
        if error_lines.blank?
          true
        else
          error_csv = CSV.generate do |csv|
            csv << FILE_HEADER
            error_lines.each do |line|
              csv << line
            end
          end
          branch.create_last_import_product_error!(error_csv: error_csv)
          false
        end
      end

      private
      def get_rows_from_file(file)
        if file.original_filename.end_with?(".csv")
          get_rows_from_csv_file(file)
        elsif file.original_filename.end_with?(".xls")
          get_rows_from_xls_file(file)
        end
      end

      def get_rows_from_csv_file(file)
        begin
          csv = CSV.parse(File.open(file.path, 'r:gb18030:utf-8') { |f| f.read }, col_sep: ",")
        rescue => e
          csv = CSV.parse(File.open(file.path, 'r:utf-8') { |f| f.read }, col_sep: ",")
        end
        validate_header(csv.first)
        # 去掉第一行
        csv.shift
        csv.each{|row| row[12] =  true if row[12] == "是" }
        rows = []
        csv.each{|row| rows << row if row[1].present? }
        rows
      end

      def get_rows_from_xls_file(file)
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet.open file.path
        sheet = book.worksheet 0
        validate_header(sheet.row(0))
        sheet.each(1){ |row| row[12] = true if row[12] == "是"}
        rows = []
        sheet.each(1){|row| rows << row if row[1].present? }
        rows
      end

      def save_product_from_row(branch, params)
        # params
        # {
        #   id:                row[0],
        #   name:              row[1],
        #   sku:               row[2],
        #   price:             row[3],
        #   vip_price:         row[4],
        #   stock_quantity:    row[5]
        #   unit_name:         row[6],
        #   description:       row[7],
        #   categories_text:   row[9],
        #   tags_text:         row[10],
        #   option_types_text: row[11],
        #   variants_text:     row[12]
        # }
        # 先跟据id查找，再根据名称查找
        product = branch.products.find_by(id:   params[:id])
        product = branch.products.find_by(name: params[:name]) if product.blank?
        if product.present?
          product.name        = params[:name]
          product.sku         = params[:sku]
          product.price       = params[:price]
          product.vip_price   = params[:vip_price]
          product.unit_name   = params[:unit_name]
          product.description = params[:description]
          product.stock_quantity = params[:stock_quantity]
          product.by_weight   =    params[:by_weight]
        else
          new_product = branch.products.build(
            name:        params[:name],
            sku:         params[:sku],
            price:       params[:price],
            vip_price:   params[:vip_price],
            unit_name:   params[:unit_name],
            description: params[:description],
            stock_quantity: params[:stock_quantity],
            by_weight:    params[:by_weight],
            availabled_at: DateTime.now
          )
        end
        @sku = params[:sku]
        current_product = product || new_product

        current_product.categories = find_or_create_categories(branch, params[:categories_text])
        current_product.tags = find_or_create_tags(branch, params[:tags_text])
        # 创建型号依赖产品的option types，必须先创建option types再创建型号
        current_product.option_types = find_or_create_option_types(branch, params[:option_types_text])
        if current_product.new_record?
          current_product.variants = find_or_create_variants(current_product, params[:variants_text])
        else
          current_variants = current_product.variants.to_a
          next_variants = find_or_create_variants(current_product, params[:variants_text])
          delete_variants = current_variants - next_variants
          delete_variants.each(&:destroy)
          current_product.variants = next_variants
        end

        if current_product.save
          [true, ""]
        else
          Ddt::Variant.restore(delete_variants.try(:map, &:id))
          [false, error_messages(current_product)]
        end
      end

      def product_row_info(product)
        [
          product.id,
          product.name,
          product.sku,
          product.price,
          product.vip_price,
          product.stock_quantity,
          product.unit_name,
          product.description.strip,
          product.categories_text(sep: "|"),
          product.tags_text(sep: "|"),
          product.option_types_text(sep: "|"),
          product.variants_text(sep: "|"),
          product.by_weight
        ]
      end

      def validate_header(header)
        if header != FILE_HEADER
          raise "文件头格式错误!"
        end
      end

      def find_or_create_categories(branch, categories_text)
        if categories_text.blank?
          []
        else
          category_chains = parse_categories_text(categories_text)
          categories = category_chains.map do |chain|
            check_and_create_category_chain(branch, chain, nil)
          end
        end
      end

      def parse_categories_text(text)
        categories = text.split("|")
        categories.map do |category|
          category.split("-")
        end
      end

      def check_and_create_category_chain(branch, chain, parent)
        if chain.blank?
          parent
        else
          name = chain.first
          category = branch.categories.find_by(name: name) || branch.categories.create(name: name, parent: parent)
          check_and_create_category_chain(branch, chain[1..-1], category)
        end
      end

      def find_or_create_tags(branch, tags_text)
        return [] if tags_text.blank?
        tags_text.split("|").map do |tag_name|
          Ddt::ProductTag.find_or_create_by(shop_id: branch.shop_id, branch_id: branch.id, name: tag_name)
        end
      end

      def find_or_create_option_types(branch, option_types_text)
        if option_types_text.blank?
          []
        else
          option_types = option_types_text.split("|")
          option_types.map do |option_type|
            branch.option_types.where(name: option_type).first_or_create
          end
        end
      end

      def find_or_create_variants(product, variants_text)
        if variants_text.blank?
          []
        else
          variants_text.split("|").map do |variant_text|
            check_and_create_variant(product, variant_text)
          end
        end
      end

      def check_and_create_variant(product, variant_text)
        params = parse_variant_text(variant_text)
        # option values
        params[:option_values] = find_or_create_option_values(product, params[:option_values_text])
        params.delete(:option_values_text)

        variant = product.variants.find params[:id] rescue nil
        if variant.present? && !variant.new_record?
          variant.update!(params)
          variant
        else
          params.delete(:id)
          new_variant = product.variants.build params
        end

      end

      def parse_variant_text(variant_text)

        segments = variant_text.split("*")
        sku = segments[1].blank? ? @sku : segments[1]
        {
          id: segments[0],
          sku: sku,
          option_values_text: segments[2],
          price: segments[3],
          vip_price: segments[4],
          stock_quantity: segments[5]
        }.with_indifferent_access
      end

      def find_or_create_option_values(product, option_values_text)
        option_values = []
        if option_values_text.present?
          option_values_text.split("#").each_with_index do |option_value_text, i|
            values = product.option_types[i].option_values
            option_values << values.where(name: option_value_text).first_or_create
          end
        end
        option_values
      end

      def error_messages(product)
        errors = product.errors
        errors.delete(:shop)
        errors.delete(:branch)

        errors.full_messages.join(";")
      end

    end
  end
end
