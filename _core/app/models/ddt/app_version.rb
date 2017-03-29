#encoding: utf-8
module Ddt
  class AppVersion < Ddt::Base

    acts_as_type :os_type, %w(android ios), %w(安卓 苹果)
    acts_as_type :terminal, %w(phone pad), %w(phone pad)

    validates_presence_of :os_type, :version_name, :version_code
    validate :version_code, format: /\A\d+\.\d+\.\d+\Z/, presence: true
    after_validation :compute_version_code

    def self.newest(os_type, terminal)
      where(os_type: os_type, terminal: terminal).order(:code => :desc).first
    end

    private
    def compute_version_code
      splits = self.version_code.split(/\./).map(&:to_i)
      self.code = (splits[0] << 24) + (splits[1] << 16) + (splits[2]<<8)
    end

  end
end
