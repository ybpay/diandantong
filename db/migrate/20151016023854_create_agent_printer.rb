class CreateAgentPrinter < ActiveRecord::Migration
  def change
    create_table :ddt_agent_printers do |t|
      t.references :agent, index: true
      t.string :printer_code
      t.string :secret
      t.string :token
      t.string :note
      t.timestamps
    end
  end
end
