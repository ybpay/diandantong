# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::PaymentService::CreatePayment, type: :service do
  let(:shop) { create(:shop_with_boss) }
  let(:order) { create(:order, shop: shop, branch: shop.branches.first, user: create(:user, shop: shop), total: 50.0) }

  describe '#call' do
    it 'creates a payment for the order' do
      pay_method = create(:payment_method, shop: shop)

      payment = described_class.new(
        order: order,
        pay_method: pay_method
      ).call

      expect(payment).to be_a(Ddt::Payment)
      expect(payment.amount.to_f).to eq(50.0)
      expect(payment.state).to eq('pending')
    end

    it 'uses custom amount when provided' do
      pay_method = create(:payment_method, shop: shop)

      payment = described_class.new(
        order: order,
        pay_method: pay_method,
        amount: 30.0
      ).call

      expect(payment.amount.to_f).to eq(30.0)
    end
  end
end

RSpec.describe Ddt::PaymentService::CompletePayment, type: :service do
  let(:shop) { create(:shop_with_boss) }
  let(:payment) { create(:payment, shop: shop, amount: 50.0, state: 'pending') }

  describe '#call' do
    it 'completes the payment' do
      completed = described_class.new(
        payment,
        transaction_id: 'TXN123456'
      ).call

      expect(completed.state).to eq('completed')
      expect(completed.transaction_id).to eq('TXN123456')
      expect(completed.paid_at).to be_within(1.second).of(Time.current)
    end
  end
end

RSpec.describe Ddt::PaymentService::PaymentGateway, type: :service do
  describe '.for' do
    it 'returns AlipayGateway for alipay' do
      payment = build(:payment)
      allow(payment).to receive(:payment_method_type).and_return('alipay')
      expect(described_class.for(payment)).to eq(Ddt::PaymentService::AlipayGateway)
    end

    it 'returns OfflineGateway for cash' do
      payment = build(:payment)
      allow(payment).to receive(:payment_method_type).and_return('cash')
      expect(described_class.for(payment)).to eq(Ddt::PaymentService::OfflineGateway)
    end

    it 'raises for unsupported methods' do
      payment = build(:payment)
      allow(payment).to receive(:payment_method_type).and_return('crypto')
      expect { described_class.for(payment) }.to raise_error(ArgumentError)
    end
  end
end
