module Ddt
  class Joke < ActiveRecord::Base

    def self.random
      # self.order("RAND()").first.try(:content)
      offset(rand(count)).first.try(:content)
    end
  end
end