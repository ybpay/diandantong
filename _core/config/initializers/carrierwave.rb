if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
    # config.aliyun_access_key = 'pUVbKo6kxk9wnPPC9LP8n5xFl9wgOo' # 不加这个，测试会出错。
  end
elsif Rails.env.development?
  CarrierWave.configure do |config|
    config.storage = :aliyun
    config.aliyun_access_id = "ByXZ5dDvtidUiKp4"
    config.aliyun_access_key = 'j38T5oIC71Cr4ky6Jdyv7dKdv9KieU'
    # 你需要在 Aliyum OSS 上面提前创建一个 Bucket
    config.aliyun_bucket = "shh-p"
    # 是否使用内部连接，true - 使用 Aliyun 局域网的方式访问  false - 外部网络访问
    config.aliyun_internal = false
    # 配置存储的地区数据中心，默认: cn-hangzhou
    # config.aliyun_area = "cn-hangzhou"
    config.aliyun_area= "cn-shanghai"
    # 使用自定义域名，设定此项，carrierwave 返回的 URL 将会用自定义域名
    # 自定于域名请 CNAME 到 you_bucket_name.oss.aliyuncs.com (you_bucket_name 是你的 bucket 的名称)
    config.aliyun_host = "http://img.shanghaihai.com"
  end
elsif Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :aliyun
    config.aliyun_access_id = "ByXZ5dDvtidUiKp4"
    config.aliyun_access_key = 'j38T5oIC71Cr4ky6Jdyv7dKdv9KieU'
    # 你需要在 Aliyum OSS 上面提前创建一个 Bucket
    config.aliyun_bucket = "shh-p"
    # 是否使用内部连接，true - 使用 Aliyun 局域网的方式访问  false - 外部网络访问
    config.aliyun_internal = false
    # 配置存储的地区数据中心，默认: cn-hangzhou
    # config.aliyun_area = "cn-hangzhou"
    config.aliyun_area= "cn-shanghai"
    # 使用自定义域名，设定此项，carrierwave 返回的 URL 将会用自定义域名
    # 自定于域名请 CNAME 到 you_bucket_name.oss.aliyuncs.com (you_bucket_name 是你的 bucket 的名称)
    config.aliyun_host = "http://img.shanghaihai.com"
  end
end