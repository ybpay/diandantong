module Ddt
  class CacheVersion < ActiveRecord::Base
    belongs_to :scope, polymorphic: true

    def version
      # js timestamp format
      updated_at.to_i * 1000
    end
  end
end
