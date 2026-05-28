# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::GuestQueuePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :destroy
  end

  describe '#pass?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :pass
  end

  describe '#accept?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :accept
  end

  describe '#cancel?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :cancel
  end

  describe '#notify?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :notify
  end

  describe '#requeue?' do
    it_behaves_like 'an ApplicationPolicy permission', :guest_queue, :requeue
  end
end
