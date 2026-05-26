# encoding: utf-8
module Ddt
  class LastImportProductError < Ddt::Base
    belongs_to :branch, class_name: 'Ddt::Branch'

    validates :error_csv, presence: true
  end
end
