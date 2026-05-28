# frozen_string_literal: true

module Ddt
  class PrintRecordPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:print_record, :show)
    end

  end
end
