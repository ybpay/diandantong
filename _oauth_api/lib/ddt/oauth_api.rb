require 'doorkeeper'
require 'oauth2'
require 'ddt_core'

module Ddt
  module OauthApi
    Doorkeeper = ::Doorkeeper
  end
end

require 'ddt/oauth_api/engine'
