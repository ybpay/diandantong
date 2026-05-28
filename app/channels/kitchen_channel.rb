class KitchenChannel < ApplicationCable::Channel
  def subscribed
    stream_from "kitchen:branch:#{current_account.branch_id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
