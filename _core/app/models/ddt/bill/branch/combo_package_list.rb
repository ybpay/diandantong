module Ddt
  module Bill
    module Branch
      class ComboPackageList < ::Ddt::Bill::Branch::Base

        def content
          text = []
          text << "<CM>套餐清单</CM>\n"
          text << "门店: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "  至: #{@end_time}"
          text << "(以订单支付时间计算)"
          text << "="*bill_width('80')
          text << "\n"
          group_items.each do |item|
            text << "#{'套餐'.fixed_width(16)} #{'售出数量'.fixed_width(8)} #{'金额'.fixed_width(8)}"
            text << "-"*bill_width('80')
            text << "#{item[:name].fixed_width(16)} #{item[:sale_quantity].fixed_width(8)} #{item[:sale_amount].fixed_width(8)}"
            item[:variants].each do |name, quantity|
              text << "  ├ #{name.fixed_width(11)} #{quantity.fixed_width(8)}"
            end
            text << "\n"
          end
          text << "="*bill_width('80')
          text << "共计数量: #{total_sale_quantity}"
          text << "共计金额: #{total_sale_amount}"
          text << "\n"
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def items
          @items ||= OrderService::Api::Statistic.combo_sale_list(query: { branch_id_eq: @branch.id, paid_at_gteq: @start_time, paid_at_lteq: @end_time }).map do |item|
            ComboPackageList::Item.new(item)
          end
        end

        def group_items
          # [
          #   {
          #     name: "套餐A"
          #     variants: { "红烧肉": 10, "回锅肉": 5 }
          #     sale_quantity:
          #     sale_amount:
          #   }
          # ]
          @group_items ||= items.group_by(&:product_name).map do |product_name, pitems|
            variants = {}
            pitems.each do |pitem|
              pitem.variants_counts.each do |variant_count|
                variant_name, quanity = variant_count
                variants[variant_name] ||= 0
                variants[variant_name] += quanity.to_i
              end
            end
            {
              name: product_name,
              variants: variants,
              sale_quantity: pitems.map(&:quantity).sum,
              sale_amount: pitems.map(&:amount).sum.round(2)
            }
          end
        end

        def total_sale_quantity
          group_items.map{|item| item[:sale_quantity]}.sum
        end

        def total_sale_amount
          group_items.map{|item| item[:sale_amount]}.sum.round(2)
        end

        class Item
          attr_accessor :product_name, :itemable_name, :itemable_id, :quantity, :price, :amount
          def initialize(params={})
            params.each do |k, v|
              self.send("#{k}=", v)
            end
          end

          # return: [['Va': '1'],['Va': '1'], ['Vb': '2']]
          def variants_counts
            itemable_name.scan(/([^\[\,]+)\*(\d+)/i)
          end
        end
      end
    end
  end
end
