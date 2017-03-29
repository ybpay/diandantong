class CreateSalesEmails < ActiveRecord::Migration
  def change
    create_table :ddt_sales_emails do |t|
      t.string :email
      t.integer :ticket
      t.timestamps
    end unless table_exists? :ddt_sales_emails
    add_index :ddt_sales_emails, :email, unique: true
    add_index :ddt_sales_emails, :ticket

  end
end
