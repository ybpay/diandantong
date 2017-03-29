#encoding: utf-8
module Ddt
  # end-user license agreement
  module EULA
    def self.protocol_path
      self.const_get LATEST_VERSION
    end

    LATEST_VERSION = :VERSION2
    VERSION1 = "/public/eulas/version1/protocol.html.erb"
    VERSION2 = "/public/eulas/version2/protocol.html.erb"
  end
end
