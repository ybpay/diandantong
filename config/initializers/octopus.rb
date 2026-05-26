if Octopus.enabled? 
  Octopus.config[Rails.env.to_s]['master'] = ActiveRecord::Base.connection.config
  ActiveRecord::Base.connection.initialize_shards(Octopus.config)
  class ActionController::Base
    before_action :select_slave_db
    protected
    def select_slave_db
      # ActiveRecord::Base.connection.current_slave_group = :slave
    end
  end
end