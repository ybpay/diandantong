if Rails.env.test? or Rails.env.cucumber?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
  end
elsif Rails.env.development?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
  end
elsif Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379/12' }
  end
end

