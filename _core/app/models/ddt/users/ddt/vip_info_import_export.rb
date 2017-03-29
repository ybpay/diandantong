# encoding:utf-8
require 'open-uri'

module Ddt
  module VipInfoImportExport
    extend ActiveSupport::Concern
    included do
    end

    FILE_HEADER = %W[
        会员号
        姓名
        手机号
        会员等级
        会员余额
        会员积分
        累计消费
        累计下单
        性别
        身份证号
        出生日期
        地址
        邮箱
        备注
      ]

    IMPORT_NOTICES = [
        '导入会员请先使用“导出会员”功能获得导入模板，参考模板格式。',
        "批量导入格式为: #{FILE_HEADER.join(" ")}",
        '会员号,姓名,手机号,会员等级为必填项, 且会员号不能重复'
      ]

    module ClassMethods

      def to_csv(options = {})
        CSV.generate(options) do |csv|
          csv << FILE_HEADER
          all.each do |vip_info|
            csv << vip_info_row_info(vip_info)
          end
        end
      end

      def to_xls
        spreadsheet = StringIO.new
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet
        sheet.row(0).concat FILE_HEADER
        all.each_with_index do |vip_info, index|
          sheet.row(index + 1).concat(vip_info_row_info(vip_info))
        end
        book.write spreadsheet
        spreadsheet.string
      end

      def update_and_create_from_uploaded_file(shop_id, uploaded_file_id)
        shop = Shop.find(shop_id)
        remove_error_csv(shop)
        uploaded_file = UploadedFile.find(uploaded_file_id)

        error_lines = []
        line_start = 1
        batch_size = 100
        rows = []
        get_rows_from_uploaded_file(uploaded_file) do |row|
          rows << row
          if rows.length >= batch_size
            part_error_lines = update_and_create_from_rows(shop, rows, line_start)
            line_start += batch_size
            error_lines.concat(part_error_lines)
            rows.clear
          end
        end
        if rows.length > 0
          part_error_lines = update_and_create_from_rows(shop, rows, line_start)
          line_start += batch_size
          error_lines.concat(part_error_lines)
          rows.clear
        end

        generate_error_csv(shop, error_lines)
      end

      def update_and_create_from_file(shop, file)
        remove_error_csv(shop)
        rows = get_rows_from_file(file)
        error_lines = update_and_create_from_rows(shop, rows)
        generate_error_csv(shop, error_lines)
      end

      private

      def update_and_create_from_rows(shop, rows, line_start = 1)
        Octopus.using(:master) do
          Rails.logger.tagged('IMPORT_VIP_INFO') do
            error_lines = []
            ActiveRecord::Base.transaction do
              params_list = rows.map do |row|
                {
                    vip_no:            row[0].to_s,
                    name:              row[1],
                    phone:             row[2].to_s,
                    vip_level_name:    row[3],
                    card_wallet_amount:row[4],
                    credits_wallet_amount:row[5],
                    total_amount:       row[6],
                    placed_orders_count: row[7],
                    sex_name:          row[8],
                    id_number:         row[9].to_s,
                    birthday:          row[10],
                    address:           row[11],
                    email:             row[12],
                    note:              row[13]
                }
              end
              part_error_lines = batch_save_vip_info_from_rows(shop, params_list, line_start)
              error_lines.concat(part_error_lines)
              Rails.logger.info("[#{shop.id}]: #{rows.length} records processed")
            end
            Rails.logger.info("[#{shop.id}] commit")
            error_lines
          end
        end
      end

      def remove_error_csv(shop)
        shop.remove_last_import_vip_info_error!
        shop.save!
      end

      def generate_error_csv(shop, error_lines)
        if error_lines.blank?
          shop.remove_last_import_vip_info_error!
          shop.save!
          true
        else
          error_csv = CSV.generate do |csv|
            csv << %W[行号 错误]
            error_lines.each do |line|
              csv << line
            end
          end
          shop.update(:last_import_vip_info_error => ShopLastImportVipInfoErrorUploader::File.new(error_csv))
          false
        end
      end

      def get_rows_from_file(file)
        if file.original_filename.end_with?(".csv")
          get_rows_from_csv_file(file)
        elsif file.original_filename.end_with?(".xls")
          get_rows_from_xls_file(file)
        else
          raise "文件格式错误"
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
        rows = []
        csv.each{|row| rows << row if row[0].present? }
        rows
      end

      def get_rows_from_xls_file(file)
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet.open file.path
        sheet = book.worksheet 0
        validate_header(sheet.row(0))
        rows = []
        sheet.each(1){|row| rows << row if row[0].present? }
        rows
      end

      def get_rows_from_uploaded_file(uploaded_file, &block)
        if uploaded_file.file.url.end_with?(".csv")
          get_rows_from_csv_uploaded_file(uploaded_file, &block)
        elsif uploaded_file.file.url.end_with?(".xls")
          get_rows_from_xls_uploaded_file(uploaded_file, &block)
        else
          raise "文件格式错误"
        end
      end

      def get_rows_from_csv_uploaded_file(uploaded_file)
        begin
          csv = CSV.parse(open(uploaded_file.file.url, "r:gb18030:utf-8") {|f| f.read }, col_sep: ",")
        rescue => e
          csv = CSV.parse(open(uploaded_file.file.url, "r:utf-8") {|f| f.read }, col_sep: ",")
        end
        validate_header(csv.first)
        # 去掉第一行
        csv.shift
        unless block_given?
          rows = []
          csv.each{|row| rows << row if row[0].present? }
          rows
        else
          csv.each{|row| yield row if row[0].present? }
        end
      end

      def get_rows_from_xls_uploaded_file(uploaded_file)
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet.open(open(uploaded_file.file.url, "r:utf-8"))
        sheet = book.worksheet 0
        validate_header(sheet.row(0))
        unless block_given?
          rows = []
          sheet.each(1){|row| rows << row if row[0].present? }
          rows
        else
          sheet.each(1){|row| yield row if row[0].present?}
        end
      end

      def batch_save_vip_info_from_rows(shop, params_list, line_start)
        error_lines = []
        vip_level_map = {}
        vip_nos = []
        shop.vip_levels.find_each do |vip_level|
          vip_level_map[vip_level.name] = vip_level
        end

        # 准备参数列表
        attrs_hash = {}
        params_hash = {}
        params_list.each_with_index do |params, index|
          vip_level = vip_level_map[params[:vip_level_name]]
          if vip_level.blank?
            error_lines << [line_start+index, "找不到该会员等级[#{params[:vip_level_name]}]，请先新建该会员等级"]
            next
          end

          vip_no = params[:vip_no]
          if vip_no.blank?
            error_lines << [line_start+index,  '会员编号不能为空']
            next
          else
            vip_nos.push(vip_no)
          end

          if params[:sex_name].present?
            sex = Ddt::VipInfo.sex_value(params[:sex_name])
            sex = params[:sex_name].include?('女') ? :female : :male if sex.blank?
          end

          attrs_hash[vip_no] = {
              vip_no: vip_no,
              vip_level: vip_level,
              sex: sex,
              name: params[:name],
              phone: params[:phone],
              id_number: params[:id_number],
              birthday: params[:birthday],
              address: params[:address],
              placed_orders_count: params[:placed_orders_count] || 0,
              email: params[:email],
              note: params[:note],
              total_amount: params[:attr_name] || 0
          }
          params_hash[vip_no] = {
              index: index,
              card_wallet_amount: params[:card_wallet_amount] || 0,
              credits_wallet_amount: params[:credits_wallet_amount] || 0
          }
        end

        # 已经存在的会员不应该处理
        # find all exists vip_info and update
        shop.vip_infos.where(vip_no: vip_nos).find_each do |vip_info|
          attrs = attrs_hash.delete(vip_info.vip_no)
          inputs = params_hash.delete(vip_info.vip_no)
          index = inputs[:index]

          # 如果将来支持覆盖再说吧
          error_lines << [line_start+index, "会员#{vip_info.vip_no}已经存在"]
          # if vip_info.update(attrs)
          #   vip_info.card_wallet.import(inputs[:card_wallet_amount])
          #   vip_info.credits_wallet.import(inputs[:credits_wallet_amount])
          # else
          #   error_lines << [line_start+index, vip_info.errors.full_messages.join(':')]
          # end
        end

        # import all non exists vip_infos
        new_vip_infos = []
        new_vip_nos = []
        default_password_hash = BCrypt::Password.create(shop.vip_info_setting.default_password, :cost => 5)
        attrs_hash.each do |vip_no, attrs|
          new_vip_infos << Ddt::VipInfo.new(
              attrs.merge({
                shop_id: shop.id,
                deleted_at: nil,
                pay_password_hash: default_password_hash
              })
          )
          new_vip_nos << vip_no
        end
        begin
          # 批量导入，如果以后VIP_INFO调整，这里需要同步处理。为了导入速度而增加冗余
          Ddt::VipInfo.import(new_vip_infos, validate: false) # batch imports
          wallet_attrs = []
          vip_infos = shop.vip_infos.where(vip_no: new_vip_nos)
          vip_infos.each do |vip_info|
            # collect wallet infos
            wallet_attrs << Ddt::Wallet.new(
                shop_id: shop.id,
                type: 'Ddt::UserCardWallet',
                owner_id: vip_info.id,
                owner_type: 'Ddt::VipInfo'
            )
            wallet_attrs << Ddt::Wallet.new(
                shop_id: shop.id,
                type: 'Ddt::UserCreditsWallet',
                owner_id: vip_info.id,
                owner_type: 'Ddt::VipInfo'
            )

            # invoke callback manually
            # vip_info.run_callbacks(:save)
            # vip_info.run_callbacks(:create)

            # vip_info.send(:create_wallets)
            # vip_info.send(:create_default_password)
          end

          Ddt::Wallet.import(wallet_attrs, validate: false)
          vip_infos.each do |vip_info|
            inputs = params_hash[vip_info.vip_no]
            vip_info.card_wallet.import(inputs[:card_wallet_amount]) if inputs[:card_wallet_amount] != 0
            vip_info.credits_wallet.import(inputs[:credits_wallet_amount]) if inputs[:credits_wallet_amount] != 0
          end

        rescue => e
          # 批量导入失败，就使用单条导入
          Rails.logger.error("[#{shop.id}] batch import error: line_start=#{line_start}, exception=#{e.message}, trace=#{e.backtrace}")
          new_vip_infos.each do |new_vip_info|
            vip_no = new_vip_info.vip_no
            inputs = params_hash[vip_no]
            index = inputs[:index]
            begin
              vip_info = shop.vip_infos.find_by(vip_no: vip_no)
              if vip_info.blank?
                # 批量 import 没通过
                if new_vip_info.save
                  new_vip_info.card_wallet.import(inputs[:card_wallet_amount]) if inputs[:card_wallet_amount] != 0
                  new_vip_info.credits_wallet.import(inputs[:credits_wallet_amount]) if inputs[:credits_wallet_amount] != 0
                else
                  error_lines << [line_start + index, "导入会员失败 #{new_vip_info.errors.full_messages.join(";")}"]
                end
              else
                # 批量 wallet 没通过
                vip_info.run_callbacks(:save)
                vip_info.run_callbacks(:create)
                vip_info.card_wallet.import(inputs[:card_wallet_amount]) if inputs[:card_wallet_amount] != 0
                vip_info.credits_wallet.import(inputs[:credits_wallet_amount]) if inputs[:credits_wallet_amount] != 0
              end
            rescue => e2
              error_lines << [line_start + index, "导入会员异常 #{e2.message}"]
            end
          end
        end
        error_lines
      end

      def save_vip_info_from_row(shop, params)
        # params
        # {
            # vip_no:            row[0],
            # name:              row[1],
            # phone:             row[2],
            # vip_level_name:    row[3],
            # card_wallet_amount:row[4],
            # credits_wallet_amount:row[5],
            # total_amount:      row[6],
            # placed_orders_count: row[7],
            # sex_name:          row[8],
            # id_number:         row[9],
            # birthday:          row[10],
            # address:           row[11],
            # email:             row[12],
            # note:              row[13]
        # }
        vip_level = shop.vip_levels.find_by(name: params[:vip_level_name])
        return [false, "找不到该会员等级，请先新建该会员等级"] if vip_level.blank?
        return [false, "会员等级不能是普通用户"] if vip_level.is_default?
        vip_no = params[:vip_no]
        return [false, "会员编号不能为空"] if vip_no.blank?
        sex = Ddt::VipInfo.sex_value(params[:sex_name])
        vip_info = shop.vip_infos.find_by(vip_no: vip_no)
        vip_info ||= shop.vip_infos.build(vip_no: vip_no)
        vip_info.sex = sex
        vip_info.vip_level = vip_level
        [:name, :phone, :id_number, :birthday, :address, :placed_orders_count, :email, :note].each do |attr_name|
          vip_info.send "#{attr_name}=", params[attr_name]
        end
        [:total_amount].each do |attr_name|
          vip_info.send "#{attr_name}=", params[attr_name]||0
        end
        if vip_info.save
          vip_info.card_wallet.import(params[:card_wallet_amount])
          vip_info.credits_wallet.import(params[:credits_wallet_amount])
          [true, ""]
        else
          [false, vip_info.errors.full_messages.join(";")]
        end
      end

      def vip_info_row_info(vip_info)
        [
          vip_info.vip_no,
          vip_info.name,
          vip_info.phone,
          vip_info.vip_level.name,
          vip_info.card_wallet.amount,
          vip_info.credits_wallet.amount,
          vip_info.total_amount,
          vip_info.placed_orders_count,
          vip_info.sex_name,
          vip_info.id_number,
          vip_info.birthday,
          vip_info.address,
          vip_info.email,
          vip_info.note
        ]
      end

      def validate_header(header)
        if header.size != FILE_HEADER.size
          raise "文件头格式错误"
        end
      end

    end
  end
end
