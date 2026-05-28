module AuthHelpers
  def auth_headers(agent)
    token = Warden::JWTAuth::UserEncoder.new.call(agent, :agent, nil).first
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
