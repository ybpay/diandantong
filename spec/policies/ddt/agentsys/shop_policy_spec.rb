# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Agentsys::ShopPolicy do
  let(:agent) { instance_double(Ddt::Agent) }
  let(:shop) { instance_double(Ddt::Shop, id: 10) }
  let(:record) { shop }
  let(:shops_scope) { instance_double('ActiveRecord::Relation') }

  before do
    allow(agent).to receive(:shops).and_return(shops_scope)
  end

  describe '#index?' do
    it 'always returns true' do
      policy = described_class.new(agent, agent: agent, record: record)
      expect(policy.index?).to be true
    end
  end

  %i[show? update? renew? suspend? activate? reset_password?].each do |action|
    describe "##{action}" do
      it 'grants when agent manages the shop' do
        allow(shops_scope).to receive(:where).with(id: 10).and_return(double(exists?: true))
        policy = described_class.new(agent, agent: agent, record: shop)
        expect(policy.public_send(action)).to be true
      end

      it 'denies when agent does not manage the shop' do
        allow(shops_scope).to receive(:where).with(id: 10).and_return(double(exists?: false))
        policy = described_class.new(agent, agent: agent, record: shop)
        expect(policy.public_send(action)).to be false
      end
    end
  end

  describe '#create?' do
    it 'grants when agent can create accounts' do
      allow(agent).to receive(:can_create_account?).and_return(true)
      policy = described_class.new(agent, agent: agent, record: record)
      expect(policy.create?).to be true
    end

    it 'denies when agent cannot create accounts' do
      allow(agent).to receive(:can_create_account?).and_return(false)
      policy = described_class.new(agent, agent: agent, record: record)
      expect(policy.create?).to be false
    end
  end
end
