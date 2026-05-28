# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Payment, type: :model do
  let(:shop) { create(:shop_with_boss) }
  let(:branch) { shop.branches.first }

  describe 'associations' do
    it { should belong_to(:payment_method).class_name('Ddt::PaymentMethod').optional }
    it { should have_many(:payment_logs).class_name('Ddt::PaymentLog') }
  end

  describe 'included modules' do
    it 'includes Discard::Model' do
      expect(described_class.ancestors).to include(Discard::Model)
    end

    it 'includes AASM' do
      expect(described_class.ancestors).to include(AASM)
    end
  end

  describe 'AASM states' do
    let(:payment) { create(:payment, shop: shop, workflow_state: 'checkout') }

    it 'starts in checkout state' do
      payment = build(:payment, shop: shop)
      expect(payment.workflow_state).to eq('checkout')
    end

    it 'transitions from checkout to processing' do
      payment.workflow_state = 'checkout'
      expect(payment.may_start_process?).to be true
    end

    it 'transitions from processing to pending' do
      payment.workflow_state = 'processing'
      expect(payment.may_do_process?).to be true
    end

    it 'transitions from pending to completed' do
      payment.workflow_state = 'pending'
      expect(payment.may_complete?).to be true
    end

    it 'transitions from completed to refunded' do
      payment.workflow_state = 'completed'
      expect(payment.may_refund?).to be true
    end

    it 'transitions from checkout to closed' do
      payment.workflow_state = 'checkout'
      expect(payment.may_do_close?).to be true
    end

    it 'transitions from processing to failed' do
      payment.workflow_state = 'processing'
      expect(payment.may_fail?).to be true
    end

    it 'transitions from pending to failed' do
      payment.workflow_state = 'pending'
      expect(payment.may_fail?).to be true
    end
  end

  describe 'scopes' do
    let!(:completed_payment) { create(:payment, shop: shop, workflow_state: 'completed', amount: 100) }
    let!(:pending_payment) { create(:payment, shop: shop, workflow_state: 'pending', amount: 50) }
    let!(:checkout_payment) { create(:payment, shop: shop, workflow_state: 'checkout', amount: 30) }

    it '.completed returns only completed payments' do
      expect(described_class.completed).to include(completed_payment)
      expect(described_class.completed).not_to include(pending_payment)
    end

    it '.imcompleted returns non-completed payments' do
      expect(described_class.imcompleted).to include(pending_payment, checkout_payment)
      expect(described_class.imcompleted).not_to include(completed_payment)
    end

    it '.checkout returns only checkout payments' do
      expect(described_class.checkout).to include(checkout_payment)
      expect(described_class.checkout).not_to include(completed_payment)
    end
  end

  describe '.of_payable' do
    it 'returns payments in checkout, processing, or pending states' do
      p1 = create(:payment, shop: shop, workflow_state: 'checkout')
      p2 = create(:payment, shop: shop, workflow_state: 'processing')
      p3 = create(:payment, shop: shop, workflow_state: 'pending')
      p4 = create(:payment, shop: shop, workflow_state: 'completed')

      payables = described_class.of_payable
      expect(payables).to include(p1, p2, p3)
      expect(payables).not_to include(p4)
    end
  end

  describe 'Discard::Model' do
    it 'includes kept scope as default scope' do
      payment = create(:payment, shop: shop)
      payment.discard!
      expect(described_class.all).not_to include(payment)
      expect(described_class.with_discarded).to include(payment)
    end
  end

  describe 'factory' do
    it 'creates a valid payment' do
      payment = create(:payment, shop: shop)
      expect(payment).to be_persisted
      expect(payment.amount).to eq(50.0)
    end
  end
end
