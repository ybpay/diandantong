# encoding:utf-8
module Ddt
  module Productable
    extend ActiveSupport::Concern
    included do

      #relationships

      #validations
      validates_presence_of :name, :description, :unit_name

      #scopes
      scope :available,           ->(){ where("ddt_products.availabled_at < ?", Time.now)}
      scope :support_delivery,    ->(is_support=true){ where(support_delivery: is_support)}
      scope :support_reservation, ->(is_support=true){ where(support_reservation: is_support)}
      scope :support_eat_in_hall, ->(is_support=true){ where(support_eat_in_hall: is_support)}
      scope :by_support_type,     ->(support_type){
        case support_type.to_sym
        when :delivery    ; support_delivery    ;
        when :reservation ; support_reservation ;
        when :eat_in_hall ; support_eat_in_hall ;
        end if support_type.present?
      }
      scope :sale_on_monday,      ->(is_sale=true){ where(sale_on_monday: is_sale)}
      scope :sale_on_tuesday,     ->(is_sale=true){ where(sale_on_tuesday: is_sale)}
      scope :sale_on_wednesday,   ->(is_sale=true){ where(sale_on_wednesday: is_sale)}
      scope :sale_on_thursday,    ->(is_sale=true){ where(sale_on_thursday: is_sale)}
      scope :sale_on_friday,      ->(is_sale=true){ where(sale_on_friday: is_sale)}
      scope :sale_on_saturday,    ->(is_sale=true){ where(sale_on_saturday: is_sale)}
      scope :sale_on_sunday,      ->(is_sale=true){ where(sale_on_sunday: is_sale)}
      scope :sale_on_wday, ->(wday){
        case wday
        when 0; sale_on_sunday;
        when 1; sale_on_monday;
        when 2; sale_on_tuesday;
        when 3; sale_on_wednesday;
        when 4; sale_on_thursday;
        when 5; sale_on_friday;
        when 6; sale_on_saturday;
        end
      }
      scope :sale_on_date,        ->(date_str){
        if date_str.present?
          if date_str.is_a? Date
            date = date_str
          elsif date_str.is_a? String
            date = Date.parse(date_str)
          end
        else
          date = Date.today
        end
        if date == Date.today
          sale_on_now
        else
          sale_on_wday(date.wday)
        end
      }
      scope :sale_on_today,        ->{ sale_on_wday(Time.now.wday) }
      scope :sale_on_now,        ->{
        shop = Ddt::Shop.current
        if shop.present?
          now = Time.now.in_time_zone(shop.time_zone).strftime('%T')
        else
          now = Time.now.strftime('%T')
        end
        sale_on_today.where("start_time < :now AND end_time > :now", { now: now })
      }
      scope :by_category,          ->(category_id){
        if category_id.present?
          # category = Ddt::Category.find_by_id(category_id)
          # if category.present?
          #   category_ids = [category.id, category.sub_ids].flatten
          #   joins("INNER JOIN ddt_categories_products ON ddt_categories_products.product_id = ddt_products.id").where("ddt_categories_products.category_id in (?)", category_ids)
          # end
          category_ids = [category_id].flatten
          joins("LEFT OUTER JOIN ddt_categories_products ON ddt_categories_products.product_id = ddt_products.id").where("ddt_categories_products.category_id in (?)", category_ids)
        end
      }
      # callbacks
    end

    module ClassMethods
    end

    def available?
      self.deleted_at == nil && self.availabled_at.present? && self.availabled_at < Time.now
    end

    def sale_on_today?
      case Time.now.wday
        when 0; self.sale_on_sunday;
        when 1; self.sale_on_monday;
        when 2; self.sale_on_tuesday;
        when 3; self.sale_on_wednesday;
        when 4; self.sale_on_thursday;
        when 5; self.sale_on_friday;
        when 6; self.sale_on_saturday;
      end
    end


  end
end
