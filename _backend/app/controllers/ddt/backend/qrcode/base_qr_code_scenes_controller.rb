module Ddt
  class Backend::Qrcode::BaseQrCodeScenesController < Backend::BaseController
    check_permission :shop, :qrcode, { index: :show }
    layout lambda { params[:layout_name]||'ddt/layouts/backend/base_qr_code_scene' }
    def index
    end
  end
end
