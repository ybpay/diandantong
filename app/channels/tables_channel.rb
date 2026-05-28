class TablesChannel < ApplicationCable::Channel
  def subscribed
    if params[:branch_id].to_s != current_account.branch_id.to_s
      reject
    else
      stream_from "tables:branch:#{current_account.branch_id}"
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
