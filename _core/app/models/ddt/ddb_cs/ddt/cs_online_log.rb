module Ddt
  class CsOnlineLog < Ddt::Base
    belongs_to :branch
    default_scope -> {order(created_at: :desc)}
  end
end
