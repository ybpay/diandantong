class Webhooks::AlertsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :verify_alertmanager_secret

  def create
    AlertWebhookJob.perform_later(params[:severity].presence || "default", payload)
    head :ok
  end

  def critical
    AlertWebhookJob.perform_later("critical", payload)
    head :ok
  end

  def warning
    AlertWebhookJob.perform_later("warning", payload)
    head :ok
  end

  private

  def payload
    request.raw_post
  end

  def verify_alertmanager_secret
    return unless ENV["ALERTMANAGER_WEBHOOK_SECRET"].present?

    received = request.headers["X-Alertmanager-Secret"] || params[:secret]
    head :forbidden unless ActiveSupport::SecurityUtils.secure_compare(
      received.to_s,
      ENV["ALERTMANAGER_WEBHOOK_SECRET"]
    )
  end
end
