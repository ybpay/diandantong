# Sidekiq Prometheus metrics middleware
if ENV["PROMETHEUS_EXPORTER_ENABLED"] == "true" && defined?(PrometheusExporter)
  require "prometheus_exporter/instrumentation/sidekiq"

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end

    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
  end

  PrometheusExporter::Instrumentation::SidekiqProcess.start if defined?(Sidekiq)
end
