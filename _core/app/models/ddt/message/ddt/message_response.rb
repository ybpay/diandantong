# encoding:utf-8
require "builder"
class Ddt::MessageResponse < Ddt::DdtEx
  include Ddt::ActsAsType
  include Ddt::BelongsToShop
  acts_as_type :msg_type, [:text, :image, :voice, :video, :music, :news, :transfer_customer_service]
  belongs_to :message_reception, class_name: 'Ddt::MessageReception'
  has_many :message_response_items, counter_cache: :article_count, dependent: :destroy, class_name: 'Ddt::MessageResponseItem'

  validates_presence_of :to_user_name, :from_user_name, :msg_type, :create_time

  validates_presence_of :content,                                 :if => :is_text?
  validates_presence_of :media_id,                                :if => "is_image? | is_voice? | is_video?"
  # validates_presence_of :thumb_media_id,                          :if => :is_music?
  # title description pic_url url

  before_validation :set_info_from_message_reception

  def set_info_from_message_reception
    if self.message_reception.present?
      self.shop_id      = self.message_reception.shop_id       if self.shop_id.blank?
      self.to_user_name   = self.message_reception.from_user_name  if self.to_user_name.blank?
      self.from_user_name = self.message_reception.to_user_name    if self.from_user_name.blank?
      self.create_time    = self.message_reception.create_time     if self.create_time.blank?
    end
  end

  def to_response_xml
    xml = ::Builder::XmlMarkup.new
    xml.xml do
      xml.ToUserName   { xml.cdata! self.to_user_name }
      xml.FromUserName { xml.cdata! self.from_user_name }
      xml.CreateTime   self.create_time
      xml.MsgType      { xml.cdata! self.msg_type.to_s }
      if self.is_text?
        xml.Content    { xml.cdata! strip_tags(self.content) }
      elsif self.is_image?
      elsif self.is_voice?
      elsif self.is_video?
      elsif self.is_music?
      elsif self.is_news?
        xml.ArticleCount  self.reload.article_count
        xml.Title         { xml.cdata! strip_tags(self.title) }                                   if self.title.present?
        xml.Description   { xml.cdata! strip_tags(self.description) }                             if self.description.present?
        xml.PicUrl        { xml.cdata! Ddt::MessageResponse.full_image_url(self.pic_url) } if self.pic_url.present?
        xml.Url           { xml.cdata! MessageResponse.full_host_url(self.url, self.to_user_name) }     if self.url.present?
        xml.Articles do
          self.message_response_items.each do |item|
            xml.item do
              xml.Title         { xml.cdata! strip_tags(item.title) }                                    if item.title.present?
              xml.Description   { xml.cdata! strip_tags(item.description) }                              if item.description.present?
              xml.PicUrl        { xml.cdata! Ddt::MessageResponse.full_image_url(item.pic_url) }  if item.pic_url.present?
              xml.Url           { xml.cdata! Ddt::MessageResponse.full_host_url(item.url, self.to_user_name) }      if item.url.present?
            end
          end
        end
      end
    end
  end

  def self.full_image_url(url)
    url.starts_with?("/") ? URI.join(Rails.application.routes.url_helpers.ddt_url, url).to_s : url
  end

  def self.full_host_url(url, to_user_name)
    #user_open_id 将用于系统绑定wechat_user，如果访问本机，一定要带上
    uri = URI.parse(url)
    root_uri = URI.parse(Rails.application.routes.url_helpers.ddt_url)
    if uri.host.nil?
      uri.query = [uri.query, "user_open_id=#{to_user_name}"].compact.join('&')
      URI.join(Rails.application.routes.url_helpers.ddt_url, uri.to_s).to_s
    elsif uri.host == root_uri.host
      uri.query = [uri.query, "user_open_id=#{to_user_name}"].compact.join('&')
      uri.to_s
    else
      url
    end
  end

  def strip_tags(str)
    @helpers ||= ActionController::Base.helpers
    @helpers.strip_tags(str).gsub(/&\w+;/i,"")
  end

end
