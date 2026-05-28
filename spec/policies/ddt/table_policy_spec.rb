# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::TablePolicy do

  describe '#show?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :show
  end

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :create
  end

  describe '#update?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :update
  end

  describe '#destroy?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :destroy
  end

  describe '#open?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :open
  end

  describe '#bind_table?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :bind_table
  end

  describe '#clear?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :clear
  end

  describe '#check_out?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :check_out
  end

  describe '#cancel_check_out?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :cancel_check_out
  end

  describe '#update_guest_num?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :update_guest_num
  end

  describe '#force_clear?' do
    it_behaves_like 'an ApplicationPolicy permission', :table, :force_clear
  end
end
