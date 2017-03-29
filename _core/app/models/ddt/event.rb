# encoding: utf-8
module Ddt
  class Event < Ddt::Base
    replicated_model

    KEY_PREFIX = 'key_'
    include ActsAsType

    acts_as_type(:event_type,
      [:click, :unmatch, :keyword_autoreply, :subscribe, :unsubscribe],
      [I18n.t('click'), I18n.t('unmatch'),I18n.t('keyword_autoreply'),I18n.t('subscribe'),I18n.t('unsubscribe')])

    acts_as_type(:system_keyword,
      ["#{KEY_PREFIX}0","#{KEY_PREFIX}1","#{KEY_PREFIX}2","#{KEY_PREFIX}3","#{KEY_PREFIX}4","#{KEY_PREFIX}9"],
      [I18n.t("#{KEY_PREFIX}0"),I18n.t("#{KEY_PREFIX}1"),I18n.t("#{KEY_PREFIX}2"),I18n.t("#{KEY_PREFIX}3"),I18n.t("#{KEY_PREFIX}4"),I18n.t("#{KEY_PREFIX}9")])

    attr_accessor :reply_type
    REPLY_TYPES = [
     ["系统消息", :system_keyword],
     ["素材", :material]
    ]

    include BelongsToShop
    belongs_to :material,  class_name: Ddt::Material

    validates :event_type, presence: true
    validates :material,   presence: true, unless: :is_system_keyword
    validates :event_key,  presence: true, uniqueness:{ message: I18n.t('event.uniq.event_key'), scope: [:shop_id, :event_type] }, if: :is_keyword_autoreply?
    validates :event_type, uniqueness:{ message: I18n.t('event.uniq.event_type'), scope: :shop_id },unless: :is_event_sharable?

    before_validation :set_defaults
    before_save :clear_prefix, if: :is_system_keyword


    def system_keyword_with_prefix
      "#{KEY_PREFIX}#{system_keyword}"
    end

    def self.clear_prefix(key)
      return key.split('_')[1]
    end


    private

    def clear_prefix
      self.system_keyword = self.system_keyword.split('_')[1]
    end

    def is_event_sharable?
      is_click? or is_keyword_autoreply?
    end

    def set_defaults
      self.is_system_keyword = false unless self.is_system_keyword
      true
    end

  end
end
