#encoding: utf-8
class Ddt::MessageReception < Ddt::DdtEx
  include Ddt::ActsAsType
  include Ddt::BelongsToShop
  acts_as_type :msg_type, [:text, :image, :voice, :video, :location, :link, :event]

  has_one :message_response, dependent: :destroy, class_name: 'Ddt::MessageResponse'


  before_validation :check_content

  validates_presence_of :to_user_name, :from_user_name, :msg_type, :create_time

  validates_presence_of :msg_id, :if => "is_text? | is_image? | is_voice? | is_video? | is_location? | is_link?"

  validates_presence_of :content,                                 :if => :is_text?
  validates_presence_of :media_id,                                :if => "is_image? | is_voice? | is_video?"
  validates_presence_of :pic_url,                                 :if => :is_image?
  validates_presence_of :voice_format,                            :if => :is_voice?
  validates_presence_of :thumb_media_id,                          :if => :is_video?
  validates_presence_of :title, :description, :url,               :if => :is_link?
  validates_presence_of :location_x, :location_y, :scale, :label, :if => :is_location?
  validates_presence_of :event,                                   :if => :is_event?
  # event_key ticket latitude longitude precision

  def wechat_account
    @wechat_account ||= self.shop.wechat_accounts.to_a.detect{|wechat_account| wechat_account.gonghao_open_id == self.to_user_name }
  end

  def wechat_user
    @wechat_user ||= Ddt::WechatUser.get_wechat_user(self.shop, self.to_user_name, self.from_user_name, Ddt::WechatUser::SOURCE_OF_MESSAGE)
  end

  def to_log_info
    self.as_json(only: [:msg_type, :to_user_name, :from_user_name, :content, :event, :event_key])
  end

  def user
    self.wechat_user.user
  end

  def response(content)
    self.create_message_response(msg_type: :text, content: content) if content.present?
  end

  def create_response_from_material(material)
    return if material.blank?
    if material.is_text?
      self.response(material.content)
    elsif material.is_news?
      message_response = self.create_message_response!(msg_type: :news)
      material.articles.each_with_index do |article, index|
        pic_url = (index == 0 ? article.image_variant(:medium) : article.image_variant(:thumb))
        message_response.message_response_items.create!(
          title: article.title,
          pic_url: pic_url,
          url: article.article_url,
          description: article.introduction)
      end
      message_response
    end
  end

  def create_response_from_event(event)
    return if event.blank?
    if event.is_system_keyword
      # 匹配到的回复类型为系统关键词回复
      Ddt::MessageHandlerMethod::System.new(self).handle_system_key(event.system_keyword)
    else
      self.create_response_from_material(event.material)
    end
  end

  def self.get_message_params_from_request(request, is_grep=false)
    request.body.rewind
    body           = request.body.read
    body           = body.gsub(/webwx_msg_cli_ver_0x1<\/xml>/, '</xml>')
    hash_body      = Hash.from_xml(body).to_options[:xml].to_options
    self.get_message_params_from_hash(hash_body, is_grep)
  end

  def self.get_message_params_from_hash(hash, is_grep=false)
    message_params = Hash[
      hash.map do |k, v|
        if v.is_a? Hash
          value = get_message_params_from_hash(v, is_grep)
        elsif v.is_a? Array
          value = v.map{|e| get_message_params_from_hash(e, is_grep)}
        else
          value = v
        end
        [k.to_s.underscore.to_sym, value]
      end
    ]
    if is_grep
      message_params.select! do |k,v|
        [
          :msg_id,
          :msg_type,
          :to_user_name,
          :from_user_name,
          :create_time,
          :content,
          :media_id,
          :pic_url,
          :format,
          :thumb_media_id,
          :location_x,
          :location_y,
          :scale,
          :label,
          :title,
          :description,
          :url,
          :event,
          :event_key,
          :ticket,
          :latitude,
          :longitude,
          :precision,
          :chosen_beacon,
          :around_beacons,
          :around_beacon,
          :uuid,
          :major,
          :minor,
          :distance
        ].include?(k)
      end
    end
    # format与Ruby内置的Kernel#format方法有冲突
    if message_params[:format].present?
      message_params[:voice_format] = message_params[:format]
      message_params.delete(:format)
    end
    message_params
  end

  def self.create_from_request(shop, request)
    message_params = self.get_message_params_from_request(request, true)
    if message_params[:msg_type] == "event" && message_params[:event] == "ShakearoundUserShake"
      # 摇一摇周边
      message_params = self.record_shake_info(message_params)
    end
    shop.message_receptions.create!(message_params)
  end

  def self.create_from_hash(shop, hash)
    message_params = self.get_message_params_from_hash(hash, true)
    shop.message_receptions.create!(message_params)
  end

  def self.calculate_message_signature(token, timestamp, nonce)
    string_array = [token, timestamp, nonce]
    Digest::SHA1.hexdigest(string_array.map(&:to_s).sort.join)
  end

  def self.validate_message_signature?(token, timestamp, nonce, signature)
    self.calculate_message_signature(token, timestamp, nonce) == signature
  end

  def self.record_shake_info(params)
    chosen_beacon = params.delete(:chosen_beacon)
    shake_info = Ddt::ShakeAround::ShakeInfo.new(
      is_from_notify: true,
      user_open_id: params[:from_user_name],
      wechat_account_wxhao: params[:to_user_name],
      shake_time: Time.at(params[:create_time].to_i)
    )
    shake_info.beacon_infos << Ddt::ShakeAround::BeaconInfo.new(chosen_beacon.merge(is_chosen: true))

    # 周边设备
    around_beacons = params.delete(:around_beacons)
    if around_beacons.present?
      around_beacons = around_beacons[:around_beacon]

      if around_beacons.is_a? Array
        around_beacons.each do |around_beacon|
          shake_info.beacon_infos << Ddt::ShakeAround::BeaconInfo.new(around_beacon.merge(is_chosen: false))
        end
      else
        # 只有一个周边设备
        shake_info.beacon_infos << Ddt::ShakeAround::BeaconInfo.new(around_beacons.merge(is_chosen: false))
      end
    end
    shake_info.save
    params
  end

  private

    def check_content
      if self.is_text?
        # 微信未编码的表情，消息为空
        self.content = "non_encoding_emoji" if self.content.blank?
      end
    end

end
