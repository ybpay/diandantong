class AddAutoPublishComment < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :auto_publish_comment, :boolean, default: true
  end
end
