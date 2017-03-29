# encoding:utf-8
require 'exception_notification/rails'

require 'exception_notification/sidekiq'



ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  last_sent_exception_mail_at = nil
  config.ignore_if do |exception, options|
    if exception.respond_to?(:send_exception_notification?) and !exception.send_exception_notification?
      true
    elsif Rails.env.production? && (last_sent_exception_mail_at.nil? or last_sent_exception_mail_at < 1.minutes.ago)
      last_sent_exception_mail_at = DateTime.now
      false
    else
      true
    end
  end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  config.add_notifier :email, {
    :email_prefix           => "[点单通bug汇报] ",
    :sender_address         => %{noreply@diandantong.com},
    :exception_recipients   => [Rails.application.config.dev_mail_group],
    :sections               => %w(request session environment trace machine)
  }

  # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
  # config.add_notifier :campfire, {
  #   :subdomain => 'my_subdomain',
  #   :token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
  # config.add_notifier :hipchat, {
  #   :api_token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
  # config.add_notifier :webhook, {
  #   :url => 'http://example.com:5555/hubot/path',
  #   :http_method => :post
  # }

end
