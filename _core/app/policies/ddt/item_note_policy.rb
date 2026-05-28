# frozen_string_literal: true

module Ddt
  class ItemNotePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:item_note, :show)
    end

    def create?
      permission_allowed?(:item_note, :create)
    end

    def update?
      permission_allowed?(:item_note, :update)
    end

    def destroy?
      permission_allowed?(:item_note, :destroy)
    end

  end
end
