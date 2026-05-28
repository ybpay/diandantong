# frozen_string_literal: true

module Ddt
  class CommentPolicy < ApplicationPolicy
    def show?
      permission_allowed?(:comment, :show)
    end

    def reply?
      permission_allowed?(:comment, :reply)
    end

    def update?
      permission_allowed?(:comment, :update)
    end

  end
end
