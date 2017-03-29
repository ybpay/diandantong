#encoding: utf-8
class Ddt::PaymentException < StandardError;
  attr_accessor :log_json_entry
  attr_accessor :message

  def initialize(message, log_json_entry)
    @message = message
    @log_json_entry = log_json_entry
  end
end
