# encoding: utf-8
module Ddt
  class AgentMaterial < Ddt::Base
    has_many :d_files, as: :owner, dependent: :destroy
    validates_presence_of :title
    accepts_nested_attributes_for :d_files, allow_destroy: true
    default_scope {order("created_at DESC")}
  end
end
