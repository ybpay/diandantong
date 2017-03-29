module Ddt
  module TestCase
    module Controller
      class Backend < TestCase::Controller::Base
        engine_route_patch use_route: :backend
      end
    end
  end
end
