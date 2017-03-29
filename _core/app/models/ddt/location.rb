#encoding: utf-8
module Ddt
  class Location < Ddt::DdtEx
    belongs_to :owner, polymorphic: true
    belongs_to :account, class_name: 'Ddt::Account', foreign_key: :owner_id, foreign_type: :owner_type, polymorphic: true
    validates_presence_of :account, :longitude, :latitude
    validates :latitude,  :numericality => {:greater_than => -90, :less_than => 90}
    validates :longitude, :numericality => {:greater_than => -180, :less_than => 180}
  end
end


