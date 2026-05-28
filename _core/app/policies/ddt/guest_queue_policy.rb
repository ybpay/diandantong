# frozen_string_literal: true

module Ddt
  class GuestQueuePolicy < ApplicationPolicy
    def show?
      permission_allowed?(:guest_queue, :show)
    end

    def create?
      permission_allowed?(:guest_queue, :create)
    end

    def update?
      permission_allowed?(:guest_queue, :update)
    end

    def destroy?
      permission_allowed?(:guest_queue, :destroy)
    end

    def pass?
      permission_allowed?(:guest_queue, :pass)
    end

    def accept?
      permission_allowed?(:guest_queue, :accept)
    end

    def cancel?
      permission_allowed?(:guest_queue, :cancel)
    end

    def notify?
      permission_allowed?(:guest_queue, :notify)
    end

    def requeue?
      permission_allowed?(:guest_queue, :requeue)
    end
  end
end
