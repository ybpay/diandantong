#encoding: utf-8
class FixHomeHotLink3 < ActiveRecord::Migration

  attr_accessor :recent_custom_weixin_info_ids

  def change
    @recent_custom_weixin_info_ids = Ddt::HomeHotLink.where(shop_type: 'mini').pluck(:custom_weixin_info_id)
    n = 0
    Ddt::CustomWeixinInfo.find_each do |info|
      update_duplicate(info.home_hot_links.where(shop_type: 'standard'))
      n += 1
      puts "#{n}th ,custom_weixin_info_id #{info.id}" if n%100 == 0
    end
  end

  def update_duplicate(hot_links)
    visited = []
    hot_links.each do |hot_link|
      same_link = visited.detect{|member| member.link == hot_link.link}
      if same_link.present?

        # label
        if same_link.label != hot_link.label
          update_by.call(:label, same_link, hot_link, defaults: ['签到', '券包'])
          next
        end

        # image
        if same_link.image != hot_link.image
          update_by.call(:image, same_link, hot_link)
          next
        end

        # icons
        if same_link.icon != hot_link.icon
          update_by.call(:icon, same_link, hot_link, defaults: ['fa-tag', 'fa-money'])
          next
        end

        # icon_background_color
        if same_link.icon_background_color != hot_link.icon_background_color
          update_by.call(:icon_background_color, same_link, hot_link, defaults: ['#ffa321', '#00c8e0'])
          next
        end

        update(same_link)

      else
        visited << hot_link
      end

    end
  end

  def update_by
    ->(column, obj1, obj2, defaults: []){
      defaults.concat [nil, ""]
      if defaults.include? obj1.send(column)
        update obj1
      elsif defaults.include? obj2.send(column)
        update obj2
      else
        if obj1.updated_at < obj2.updated_at
          update obj1
        else
          update obj2
        end
      end
    }
  end

  def update(obj)
    if (@recent_custom_weixin_info_ids.include?(obj.custom_weixin_info_id) rescue false)
      obj.destroy
    else
      obj.update(shop_type: 'mini')
    end
  end

end
