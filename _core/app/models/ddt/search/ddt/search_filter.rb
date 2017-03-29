module Ddt
  class SearchFilter < Ddt::Base
    include Ddt::BelongsToShop

    # shop_id
    # branch_id
    # name
    # model_type
    # match_policy
    # ransack_q
    # state
    # timestamps


    has_many :search_results, class_name: 'Ddt::SearchResult', dependent: :destroy


    validates_presence_of :name, :model_type


    acts_as_type :match_policy, %i[all any], %w[满足所有, 满足任一]
    acts_as_type :state, %i[init computing completed], %W[初始化完成 计算中 计算完成]

    scope :by_type, ->(model_type){ where(model_type: model_type)}

    state_machine :state, :initial => :init do
      event :compute do
        transition :init => :computing
      end
      event :recompute do
        transition :completed => :computing
      end
      event :complete do
        transition :computing => :completed
      end
    end

    def last_result
      search_results.order(created_at: :desc).first
    end

    def start_compute
      self.compute!
      run_worker
    end

    def start_recompute
      self.recompute!
      run_worker
    end

    def run_worker
      Ddt::SearchFilterWorker.perform_in(1.second, self.id)
    end

    def perform
      model_ids = self.model_type.constantize.limit(10000).ransack(YAML.load(self.ransack_q)).result.pluck(:id)
      self.search_results.create(shop_id: self.shop_id, count: model_ids.size, model_ids_str: model_ids.join(','))
      self.touch(:last_search_at)
      self.complete
    end

  end
end
