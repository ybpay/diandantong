# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::GuestQueue, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }
  let(:queue_setting) { create(:queue_setting, shop: shop, branch: branch) }

  describe 'associations' do
    it { should belong_to(:queue_setting) }
  end

  describe 'validations' do
    it { should validate_presence_of(:queue_setting) }
    it { should validate_presence_of(:guest_num) }
    it { should validate_numericality_of(:guest_num).is_greater_than_or_equal_to(1).is_less_than(200) }
  end

  describe 'included modules' do
    it 'includes AASM' do
      expect(described_class.ancestors).to include(AASM)
    end
  end

  describe 'AASM states' do
    let(:guest_queue) { create(:guest_queue, shop: shop, branch: branch, queue_setting: queue_setting) }

    it 'starts in queueing state' do
      expect(guest_queue.workflow_state).to eq('queueing')
    end

    it 'transitions from queueing to accepted' do
      expect(guest_queue.may_accept?).to be true
    end

    it 'transitions from queueing to canceled' do
      expect(guest_queue.may_cancel?).to be true
    end

    it 'transitions from queueing to past' do
      expect(guest_queue.may_pass?).to be true
    end

    it 'transitions from accepted to queueing (requeue)' do
      guest_queue.update!(workflow_state: 'accepted')
      expect(guest_queue.may_requeue?).to be true
    end

    it 'transitions from past to queueing (requeue)' do
      guest_queue.update!(workflow_state: 'past')
      expect(guest_queue.may_requeue?).to be true
    end
  end

  describe 'default scope' do
    it 'orders by created_at ascending' do
      gq1 = create(:guest_queue, shop: shop, branch: branch, queue_setting: queue_setting)
      gq2 = create(:guest_queue, shop: shop, branch: branch, queue_setting: queue_setting)
      expect(described_class.all.to_a).to eq([gq1, gq2])
    end
  end

  describe '#front_guest_no' do
    it 'returns the guest number' do
      gq = create(:guest_queue, shop: shop, branch: branch, queue_setting: queue_setting, guest_no: 'A001')
      expect(gq.front_guest_no).to eq('A001')
    end
  end

  describe 'factory' do
    it 'creates a valid guest queue' do
      gq = create(:guest_queue, shop: shop, branch: branch, queue_setting: queue_setting)
      expect(gq).to be_persisted
      expect(gq.guest_num).to be >= 1
      expect(gq.guest_no).to be_present
    end
  end
end
