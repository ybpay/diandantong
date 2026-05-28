class TablesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "tables:branch:#{params[:branch_id]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
