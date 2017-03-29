module Ddt
  class ApiKey < Ddt::Base
    validates_presence_of :name, :access_token
    validates_uniqueness_of :name, :access_token

    before_validation do 
      self.access_token = ApiAuth.generate_secret_key if self.access_token.blank?
    end
  end
end
