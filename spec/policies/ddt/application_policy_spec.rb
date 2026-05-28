# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::ApplicationPolicy do
  subject { described_class }

  let(:user) { nil }
  let(:account) { instance_double(Ddt::Account) }
  let(:shop) { instance_double(Ddt::Shop) }
  let(:branch) { nil }

  describe 'authorization context' do
    it 'authorizes account with allow_nil' do
      expect { described_class.new(user, record: nil) }.not_to raise_error
    end
  end

  describe '#admin?' do
    context 'when account is admin' do
      let(:policy) do
        described_class.new(user, account: account, shop: shop, branch: branch, record: nil)
      end

      before { allow(account).to receive(:is_admin?).and_return(true) }

      it 'returns true' do
        expect(policy.send(:admin?)).to be true
      end
    end

    context 'when account is nil' do
      let(:policy) do
        described_class.new(user, account: nil, shop: shop, branch: branch, record: nil)
      end

      it 'returns false' do
        expect(policy.send(:admin?)).to be false
      end
    end
  end

  describe '#permission_allowed?' do
    let(:policy) do
      described_class.new(user, account: account, shop: shop, branch: branch, record: nil)
    end

    context 'when account is admin' do
      before { allow(account).to receive(:is_admin?).and_return(true) }

      it 'always returns true' do
        expect(policy.send(:permission_allowed?, :any_target, :any_action)).to be true
      end
    end

    context 'when account is nil' do
      let(:account) { nil }

      it 'returns false' do
        expect(policy.send(:permission_allowed?, :any_target, :any_action)).to be false
      end
    end

    context 'when account has permission at shop scope' do
      let(:branch) { nil }

      before do
        allow(account).to receive(:is_admin?).and_return(false)
        allow(account).to receive(:can?).with(:shop, :product, :show, branch_id: nil).and_return(true)
      end

      it 'delegates to account.can? with shop scope' do
        expect(policy.send(:permission_allowed?, :product, :show)).to be true
      end
    end

    context 'when account has permission at branch scope' do
      let(:branch) { instance_double(Ddt::Branch, id: 42) }

      before do
        allow(account).to receive(:is_admin?).and_return(false)
        allow(account).to receive(:can?).with(:branch, :product, :show, branch_id: 42).and_return(true)
      end

      it 'delegates to account.can? with branch scope' do
        expect(policy.send(:permission_allowed?, :product, :show)).to be true
      end
    end

    context 'when account lacks permission' do
      before do
        allow(account).to receive(:is_admin?).and_return(false)
        allow(account).to receive(:can?).with(:shop, :product, :show, branch_id: nil).and_return(false)
      end

      it 'returns false' do
        expect(policy.send(:permission_allowed?, :product, :show)).to be false
      end
    end
  end
end
