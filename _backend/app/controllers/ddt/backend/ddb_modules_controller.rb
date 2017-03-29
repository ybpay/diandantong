module Ddt
  class Backend::DdbModulesController < Backend::BaseController
    check_permission :shop, :ddb_module, { [:show, :index, :delivery_setting, :queue_setting, :guest_queue, :reservation_time_point, :table, :table_zone] => :show, [:edit, :update, :destroy, :validate] => :update}
  end
end