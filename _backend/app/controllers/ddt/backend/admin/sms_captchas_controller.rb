#encoding: utf-8
module Ddt
  module Backend
    class Admin::SmsCaptchasController < Ddt::Backend::BaseAdminController

      def index
        @search_params = params[:q]
        @q = Ddt::SmsCaptcha.ransack(@search_params)
        @queried_sms_captchas = @q.result.order(:updated_at => :desc)
        respond_to do |format|
          format.html {
            @sms_captchas = @queried_sms_captchas.paginate(page: params[:page], :per_page => 25)
          }
          format.csv {
            # 导出时不需要分页
            send_data @queried_sms_captchas.to_csv, filename: 'sms_captcha.csv'
          }
        end
      end

      def destroy
        @sms_captcha = Ddt::SmsCaptcha.find(params[:id])
        @sms_captcha.destroy
        respond_to do |format|
          format.html { redirect_to backend_sms_captchas_path, notice: "已成功删除短信验证码记录" }
          format.json { head :no_content }
        end
      end

      def export
        @sms_captchas = Ddt::SmsCaptcha.ransack(params[:q]).result.order(:updated_at)
        respond_to do |format|
          if @tables.size > 0
            suffix = params[:page].present? ? "_part_#{params[:page]}" : ""
            if %W[h v].include? params[:version]
              version = params[:version].to_sym
              tmp_zip_file = Ddt::QrCodeScenesExport.export_table_sticker(@tables.map(&:qr_code_scene), @current_branch, version)
              format.zip { send_file tmp_zip_file.path, :filename => "export_qr_codes#{suffix}.zip" }
            else
              format.zip { send_data "参数错误", :filename => "params_error.txt"}
            end
          else
            format.zip { send_data "您还没有设置桌台", :filename => "table_notset.txt"}
          end
        end

      end

    end
  end
end