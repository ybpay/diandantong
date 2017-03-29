#encoding: utf-8
# Schema Information
# Table name: base_users
# no special informations
module Ddt
  class PhoneUser < Ddt::BaseUser
    valid_phone :phone

    def to_label
      [self.phone, self.email, self.id].select(&:present?).join(" - ")
    end
  end
end
