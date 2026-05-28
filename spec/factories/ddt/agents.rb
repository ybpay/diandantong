FactoryBot.define do
  factory :agent, class: 'Ddt::Agent' do
    sequence(:email) { |n| "agent#{n}@example.com" }
    sequence(:agent_no) { |n| "AG#{n.to_s.rjust(6, '0')}" }
    sequence(:name) { |n| "测试代理#{n}" }
    sequence(:phone) { |n| "1370000#{n.to_s.rjust(4, '0')}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    discount { 0.35 }
    balance { 1000.0 }
    agent_type { :normal_level }

    after(:create) do |agent|
      create(:agent_rel, agent: agent, agent_to: 1.year.from_now)
    end

    trait :oem do
      is_oem { true }
      brand { '测试品牌' }
      company_name { '测试公司' }
    end

    trait :expired do
      after(:create) do |agent|
        agent.agent_rels.update_all(agent_to: 1.day.ago)
      end
    end
  end

  factory :agent_rel, class: 'Ddt::AgentRel' do
    association :agent
    agent_from { Time.current }
    agent_to { 1.year.from_now }
    sequence(:zone_code) { |n| "ZN#{n}" }
  end
end
