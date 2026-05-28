class AlertWebhookJob < ApplicationJob
  queue_as :low

  def perform(severity, raw_payload)
    payload = JSON.parse(raw_payload)
    Rails.logger.warn(
      message: "Alertmanager alert received",
      severity: severity,
      alerts: payload["alerts"]&.map { |a| a["labels"] },
      status: payload["status"]
    )
  end
end
