# encoding: utf-8
module Ddt
  module Schedule
    class Base
      include Sidekiq::Worker
      sidekiq_options :retry => 0, :queue => :seldom
      def perform
      end

      def is_production?
        Ddt::Shop.first.name == "点单通官方演示系统"
      end
    end
  end
end
