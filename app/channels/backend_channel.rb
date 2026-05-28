class BackendChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_account
  end

  def unsubscribed
    stop_all_streams
  end
end
