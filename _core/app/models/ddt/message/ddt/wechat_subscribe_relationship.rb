#encoding: utf-8
module Ddt
  class WechatSubscribeRelationship < Ddt::Base

    validates_presence_of :gonghao_open_id, :user_open_id
    validates :gonghao_open_id, gonghao: true

    #用来记录所有的公众号open_id与用户open_id的关系，紧急时刻用于数据恢复
    # 这里的 user_open_id 实际上是 unique_open_id
    def self.add_relationship(gonghao_open_id, user_open_id)
      relation_ship = self.find_by_user_open_id(user_open_id)
      if relation_ship.nil?
        relation_ship = WechatSubscribeRelationship.create!(:gonghao_open_id => gonghao_open_id, :user_open_id => user_open_id)
      elsif relation_ship.gonghao_open_id != gonghao_open_id
        raise "该用户的订阅关系记录已存在，但公众号不一致，原公众号OpenId为#{relation_ship.gonghao_open_id},现公众号OpenId为#{gonghao_open_id}"
      end
    end
  end
end
