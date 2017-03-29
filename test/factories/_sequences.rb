FactoryGirl.define do
  sequence(:slug) { |n| "slug#{n}"}
  sequence(:login_id) { |n| "login_id#{n}"}
  sequence(:name) { |n| "name#{n}"}
  sequence(:content, aliases: [:statement]) { |n| "content#{n}"}
  sequence(:email){ |n| "email_#{n}@diandantong.com"}
  sequence(:phone, aliases: [:telephone]) { |n| "1571576%.04d" % n}
  sequence(:image){ Rack::Test::UploadedFile.new("#{Rails.root}/test/support/fixtures/image.jpg") }
  sequence(:user_open_id){ |n| "oi3Hyjs7JVhNdNJQafmVx_xDCzVI#{n}" }
  sequence(:vip_no){ |n| "vip_no_#{n}"}
  sequence(:sku){ |n| "sku#{n}"}
end
