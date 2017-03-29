if Rails.env.test? or Rails.env.cucumber?

elsif Rails.env.development? or Rails.env.production?
  Devise::Async.setup do |config|
    config.enabled = true
    config.backend = :sidekiq
    config.queue   = :email
  end
end