
# Send STDERR to a separate file
if 'production' == Rails.env
  error_logger = ActiveSupport::Logger.new(Rails.root + 'log/production.error.log')
  error_logger.level = Logger::ERROR
  Rails.logger.extend(ActiveSupport::Logger.broadcast(error_logger))
end
