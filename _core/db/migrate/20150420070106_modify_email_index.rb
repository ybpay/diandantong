class ModifyEmailIndex < ActiveRecord::Migration
  def change
  	if index_exists? :ddt_accounts, :email
	    remove_index :ddt_accounts, :email
	end

	unless index_exists? :ddt_accounts, "ddt_accounts_email"
	    add_index :ddt_accounts, [:email, :deleted_at], :name=> "ddt_accounts_email", :length => {"email" => 191, "deleted_at"=> nil}, unique: true
	end
  end
end
