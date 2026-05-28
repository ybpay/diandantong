class CreateDdtAgentJwtDenylist < ActiveRecord::Migration[8.1]
  def change
    create_table :ddt_agent_jwt_denylist do |t|
      t.string :jti, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
