# Compatibility shim: PrivatePub → ActionCable
#
# Provides the same `PrivatePub.publish_to(channel, data)` interface
# but broadcasts through ActionCable instead of Faye.
#
# Usage remains the same:
#   PrivatePub.publish_to("/orders/#{shop_id}", msg: "new_order")
#
# On the client side, subscribe via ActionCable:
#   App.cable.subscriptions.create { channel: "NotificationsChannel" }
#
module PrivatePub
  def self.publish_to(channel, data = {})
    ActionCable.server.broadcast(channel_name(channel), data)
  end

  def self.subscription(options = {})
    { channel: channel_name(options[:channel]) }
  end

  private

  def self.channel_name(raw)
    raw.to_s.sub(%r{\A/}, '').gsub('/', '_')
  end
end
