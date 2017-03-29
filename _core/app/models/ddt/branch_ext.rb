#encoding: utf-8
module Ddt
  class BranchExt < Ddt::Base
    belongs_to :branch, class_name: "Ddt::Branch"
  end
end
