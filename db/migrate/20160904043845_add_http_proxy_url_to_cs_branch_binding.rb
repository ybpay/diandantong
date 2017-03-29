class AddHttpProxyUrlToCsBranchBinding < ActiveRecord::Migration
  def change
    add_column :ddt_cs_branch_bindings, :http_proxy_url, :string
  end
end
