# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Agentsys::AgentPolicy do
  let(:agent) { instance_double(Ddt::Agent) }
  let(:user) { agent }
  let(:record) { nil }
  let(:policy) { described_class.new(user, agent: agent, record: record) }

  describe '#show?' do
    it 'grants when agent matches user' do
      expect(policy.show?).to be true
    end

    it 'denies when agent does not match user' do
      other_agent = instance_double(Ddt::Agent)
      policy = described_class.new(other_agent, agent: agent, record: record)
      expect(policy.show?).to be false
    end
  end

  describe '#update?' do
    it 'grants when agent matches user' do
      expect(policy.update?).to be true
    end

    it 'denies when agent does not match user' do
      other_agent = instance_double(Ddt::Agent)
      policy = described_class.new(other_agent, agent: agent, record: record)
      expect(policy.update?).to be false
    end
  end

  describe '#create_sub_agent?' do
    it 'grants when agent matches user' do
      expect(policy.create_sub_agent?).to be true
    end
  end

  describe '#manage_sub_agents?' do
    it 'grants when agent matches user' do
      expect(policy.manage_sub_agents?).to be true
    end
  end
end
