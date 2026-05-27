# frozen_string_literal: true

class CreateSolidCableTable < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_cable_messages do |t|
      t.binary   :channel, null: false, limit: 1024
      t.binary   :payload, null: false, limit: 536870912
      t.datetime :created_at, null: false
      t.integer  :channel_hash, null: false

      t.index [:channel], name: :index_solid_cable_messages_on_channel
      t.index [:channel_hash, :created_at], name: :index_solid_cable_on_channel_hash_and_created
      t.index [:created_at], name: :index_solid_cable_messages_on_created_at
    end
  end
end
