# frozen_string_literal: true

module Ddt
  class SignRecordPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:sign_record, :show)
    end

  end
end
