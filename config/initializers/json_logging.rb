# Structured JSON logging for production (Loki-compatible)
if ENV["RAILS_LOG_FORMAT"] == "json" && Rails.env.production?
  require "json"
  require "active_support/logger"
  require "active_support/tagged_logging"

  # Middleware that propagates ActionDispatch request_id into Thread.current
  # so the JSON formatter can include it in every log line.
  class RequestIdMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request_id = env["action_dispatch.request_id"]
      Thread.current[:request_id] = request_id if request_id
      @app.call(env)
    ensure
      Thread.current[:request_id] = nil
    end
  end

  Rails.application.config.middleware.insert_after ActionDispatch::RequestId, RequestIdMiddleware

  class JsonFormatter < ActiveSupport::Logger::Formatter
    def call(severity, timestamp, _progname, message)
      payload = {
        timestamp: timestamp.iso8601(6),
        level: severity,
        environment: Rails.env
      }

      if message.is_a?(Hash)
        payload.merge!(message)
      else
        payload[:message] = message.to_s.strip
      end

      if request_id = Thread.current[:request_id]
        payload[:request_id] = request_id
      end

      "#{payload.to_json}\n"
    end
  end

  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = JsonFormatter.new
  Rails.application.config.logger = ActiveSupport::TaggedLogging.new(logger)
end
