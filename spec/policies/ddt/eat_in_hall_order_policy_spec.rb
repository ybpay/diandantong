# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::EatInHallOrderPolicy do

  describe '#create?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :create
  end

  describe '#change_table?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :change_table
  end

  describe '#merge_table?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :merge_table
  end

  describe '#move_itemable?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :move_itemable
  end

  describe '#bind_reservation_order?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :bind_reservation_order
  end

  describe '#trace_waiter?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :trace_waiter
  end

  describe '#allow_selfpay?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :allow_selfpay
  end

  describe '#update_guest_num?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :update_guest_num
  end

  describe '#change_line_item_weight?' do
    it_behaves_like 'an ApplicationPolicy permission', :eat_in_hall_order, :change_line_item_weight
  end
end
