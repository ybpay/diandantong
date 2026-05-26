module Ddt
  class RechargeProduct < Ddt::Base
    include BelongsToShop
    include ListScope

    include Ddt::SoftDeletable

    acts_as_list scope: [:shop_id, :deleted_at]

    validates_presence_of :name, :price, :recharge_amount
    validates_numericality_of :price, :recharge_amount, :greater_than => 0
    validates_numericality_of :extra_credits, :greater_than_or_equal_to => 0
    validates_numericality_of :first_recharge_available_amount, :greater_than_or_equal_to => 0

    # support_all_branch:boolean
    has_and_belongs_to_many :branches, :join_table => 'ddt_recharge_products_branches', class_name: 'Ddt::Branch'
    has_and_belongs_to_many :branch_groups, :join_table => 'ddt_recharge_products_branch_groups', class_name: 'Ddt::BranchGroup'

    ids_string_for :branches, :branch_groups

    default_scope ->{ list_order }
    scope :support_all_branch, ->{ where(support_all_branch: true)}
    scope :support_of_branch, ->(branch_id){
      if branch_id.present?
        branch = ::Ddt::Branch.find(branch_id)
        branch_group_ids = branch.branch_group_ids
        if branch_group_ids.present?
          includes(:branches).references(:diandnabao_branches)
            .includes(:branch_groups).references(:diandnabao_branch_groups)
            .where("support_all_branch = 1 or (support_all_branch = 0 and (ddt_branches.id = #{branch_id} or ddt_branch_groups.id in (#{branch_group_ids.join(',')})))")
        else
          includes(:branches).references(:diandnabao_branches)
            .where("support_all_branch = 1 or (support_all_branch = 0 and ddt_branches.id = #{branch_id})")
        end
      end
    }

    def branch
      self.shop.abstract_branch
    end

    def branch_id
      branch.id
    end

    def branch_names
      self.branches.map(&:name).join(",")
    end

    def branch_group_names
      self.branch_groups.map(&:name).join(",")
    end

    concerning :ItemableMethod do
      include Itemable
      included do
        # column : name price
        def sku
        end

        def itemable_name
          self.name
        end
        alias_method :product_name, :itemable_name

        def stock_enough?(quantity=1)
          true
        end

        def stock_quantity
          999999
        end

        def original_price
          price
        end

        def vip_price
          price
        end

        def unit_name
          ''
        end

        def avatar_url
        end

        def update_sale_quantity(line_item_quantity)
          increment!(:sales_count, line_item_quantity)
        end
      end
    end
  end
end
