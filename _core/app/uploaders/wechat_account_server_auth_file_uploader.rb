class WechatAccountServerAuthFileUploader < CarrierWave::Uploader::Base
  def store_dir
    'uploads/wechat_account_server_auth_files'
  end

  storage :aliyun
end
