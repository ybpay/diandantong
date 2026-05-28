# frozen_string_literal: true

# Shared context for testing policies that inherit from ApplicationPolicy.
# Include via: it_behaves_like 'an ApplicationPolicy permission', :target, :action
RSpec.shared_examples 'an ApplicationPolicy permission' do |target, action|
  let(:user) { nil }
  let(:account) { instance_double(Ddt::Account) }
  let(:shop) { instance_double(Ddt::Shop) }
  let(:branch) { nil }
  let(:record) { nil }
  let(:policy) { described_class.new(user, account: account, shop: shop, branch: branch, record: record) }

  context 'when account is admin' do
    before { allow(account).to receive(:is_admin?).and_return(true) }

    it "grants #{action}?" do
      expect(policy.public_send(:"#{action}?")).to be true
    end
  end

  context 'when account has permission' do
    before do
      allow(account).to receive(:is_admin?).and_return(false)
      allow(account).to receive(:can?).with(:shop, target, action, branch_id: nil).and_return(true)
    end

    it "grants #{action}?" do
      expect(policy.public_send(:"#{action}?")).to be true
    end
  end

  context 'when account lacks permission' do
    before do
      allow(account).to receive(:is_admin?).and_return(false)
      allow(account).to receive(:can?).with(:shop, target, action, branch_id: nil).and_return(false)
    end

    it "denies #{action}?" do
      expect(policy.public_send(:"#{action}?")).to be false
    end
  end

  context 'when account is nil' do
    let(:account) { nil }

    it "denies #{action}?" do
      expect(policy.public_send(:"#{action}?")).to be false
    end
  end

  context 'with branch context' do
    let(:branch) { instance_double(Ddt::Branch, id: 99) }

    before do
      allow(account).to receive(:is_admin?).and_return(false)
      allow(account).to receive(:can?).with(:branch, target, action, branch_id: 99).and_return(true)
    end

    it "checks permission at branch scope" do
      expect(policy.public_send(:"#{action}?")).to be true
    end
  end
end
