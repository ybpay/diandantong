# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ddt::Agentsys::BrandPolicy do
  let(:agent) { instance_double(Ddt::Agent) }
  let(:record) { nil }

  %i[index? show? create? update?].each do |action|
    describe "##{action}" do
      it 'grants when agent is OEM' do
        allow(agent).to receive(:is_oem?).and_return(true)
        policy = described_class.new(agent, agent: agent, record: record)
        expect(policy.public_send(action)).to be true
      end

      it 'denies when agent is not OEM' do
        allow(agent).to receive(:is_oem?).and_return(false)
        policy = described_class.new(agent, agent: agent, record: record)
        expect(policy.public_send(action)).to be false
      end
    end
  end
end
