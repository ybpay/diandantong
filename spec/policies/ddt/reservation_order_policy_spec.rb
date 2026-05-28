# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ReservationOrderPolicy do

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :reservation_order, :create
  end

  describe '#change_to_eat_in_hall?' do
    it_behaves_like 'an ApplicationPolicy permission', :reservation_order, :change_to_eat_in_hall
  end

  describe '#bind_table?' do
    it_behaves_like 'an ApplicationPolicy permission', :reservation_order, :bind_table
  end

  describe '#edit_reservation_info?' do
    it_behaves_like 'an ApplicationPolicy permission', :reservation_order, :edit_reservation_info
  end
end
