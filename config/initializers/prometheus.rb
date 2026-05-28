# Prometheus metrics exporter configuration
if ENV["PROMETHEUS_EXPORTER_ENABLED"] == "true" && defined?(PrometheusExporter)
  require "prometheus_exporter/middleware"
  require "prometheus_exporter/instrumentation"

  PrometheusExporter::Client.default =
    PrometheusExporter::Client.new(
      host: ENV.fetch("PROMETHEUS_EXPORTER_HOST", "127.0.0.1"),
      port: ENV.fetch("PROMETHEUS_EXPORTER_PORT", 9394).to_i,
      custom_labels: { environment: Rails.env }
    )

  PrometheusExporter::Instrumentation::Process.start(type: "rails")
  PrometheusExporter::Instrumentation::ActiveRecord.start if defined?(ActiveRecord::Base)

  Rails.application.config.middleware.insert_before(
    Rack::Runtime,
    PrometheusExporter::Middleware,
    client: PrometheusExporter::Client.default
  )
end
