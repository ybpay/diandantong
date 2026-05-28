# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Agentsys::RechargeRecordPolicy do
  let(:agent) { instance_double(Ddt::Agent, id: 1) }
  let(:record) { instance_double('RechargeRecord', agent_id: 1, shop_id: 10) }
  let(:policy) { described_class.new(agent, agent: agent, record: record) }

  describe '#index?' do
    it 'always returns true' do
      expect(policy.index?).to be true
    end
  end

  describe '#show?' do
    it 'grants when record belongs to agent' do
      expect(policy.show?).to be true
    end

    it 'denies when record belongs to another agent' do
      other_record = instance_double('RechargeRecord', agent_id: 999, shop_id: 10)
      policy = described_class.new(agent, agent: agent, record: other_record)
      expect(policy.show?).to be false
    end
  end

  describe '#create?' do
    it 'grants when agent manages the shop' do
      shops = instance_double('ActiveRecord::Relation')
      allow(agent).to receive(:shops).and_return(shops)
      allow(shops).to receive(:where).with(id: 10).and_return(double(exists?: true))
      expect(policy.create?).to be true
    end

    it 'denies when agent does not manage the shop' do
      shops = instance_double('ActiveRecord::Relation')
      allow(agent).to receive(:shops).and_return(shops)
      allow(shops).to receive(:where).with(id: 10).and_return(double(exists?: false))
      expect(policy.create?).to be false
    end
  end
end
