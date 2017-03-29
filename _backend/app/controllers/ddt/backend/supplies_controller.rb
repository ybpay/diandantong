module Ddt
  class Backend::SuppliesController < Backend::BaseController
    check_permission :shop, :supply, :show

    def queue_qr_codes
      @q = @current_shop.wechat_qr_code_scenes.where(
        wechat_scene_type: :limit,
        limit_scene_type: :queue_message
      ).where(branch_id: managed_branch_ids).ransack(params[:q])
      @queue_qr_codes = @q.result.paginate(page: params[:page] || 1, per_page: params[:per_page] || 20)
    end

    def export_queue_qr_code
      @queue_qr_code = @current_shop.wechat_qr_code_scenes.where(
          id: params[:id],
          wechat_scene_type: :limit,
          limit_scene_type: :queue_message
      ).first

      respond_to do |format|
        if @queue_qr_code.present?
          tmp_zip_file = QrCodeScenesExport.export_queue_qr_codes(@queue_qr_code, "queue_qr_code_#{@queue_qr_code.id}")
          format.zip { send_file tmp_zip_file.path, :filename => "queue_qr_code_#{@queue_qr_code.id}.zip" }
        else
          format.zip { send_data '您请求的排号二维码不存在', :filename => 'queue_qr_code_not_set.txt'}
        end
      end
    end

    def door_stickers
      @q = @current_shop.wechat_qr_code_scenes.where(
        wechat_scene_type: :limit,
        limit_scene_type: :branch_message
      ).where(branch_id: managed_branch_ids).ransack(params[:q])
      @door_stickers = @q.result.paginate(page: params[:page] || 1, per_page: params[:per_page] || 20)
    end

    def export_door_sticker
      @door_sticker = @current_shop.wechat_qr_code_scenes.where(
          id: params[:id],
          wechat_scene_type: :limit,
          limit_scene_type: :branch_message
      ).first

      respond_to do |format|
        if @door_sticker.present?
          tmp_zip_file = QrCodeScenesExport.export_door_stickers(@door_sticker, "门贴#{@door_sticker.id}")
          format.zip { send_file tmp_zip_file.path, :filename => "门贴#{@door_sticker.id}.zip" }
        else
          format.zip { send_data '您请求的门店二维码不存在', :filename => 'door_sticker_not_set.txt'}
        end
      end
    end

    def fastfood_stickers
      @q = @current_shop.wechat_qr_code_scenes.where(
        wechat_scene_type: :limit,
        limit_scene_type: :fastfood_message
      ).where(branch_id: managed_branch_ids).ransack(params[:q])
      @fastfood_stickers = @q.result.paginate(page: params[:page] || 1, per_page: params[:per_page] || 20)
    end

    def export_fastfood_sticker
      @fastfood_sticker = @current_shop.wechat_qr_code_scenes.where(
          id: params[:id],
          wechat_scene_type: :limit,
          limit_scene_type: :fastfood_message
      ).first

      respond_to do |format|
        if @fastfood_sticker.present?
          tmp_zip_file = QrCodeScenesExport.export_fastfood_stickers(@fastfood_sticker, "快餐海报#{@fastfood_sticker.id}")
          format.zip { send_file tmp_zip_file.path, :filename => "快餐海报#{@fastfood_sticker.id}.zip" }
        else
          format.zip { send_data '您请求的快餐二维码不存在', :filename => 'fastfood_sticker_not_set.txt'}
        end
      end
    end

  end
end
