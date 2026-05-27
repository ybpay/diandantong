# frozen_string_literal: true

class CreateSolidQueueTables < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_queue_jobs, id: :primary_key do |t|
      t.string   :queue_name, null: false
      t.string   :class_name, null: false
      t.text     :arguments
      t.integer  :priority, default: 0, null: false
      t.string   :active_job_id
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.string   :concurrency_key
      t.datetime :created_at, null: false

      t.index [:queue_name, :scheduled_at], name: :index_solid_queue_jobs_on_queue_and_scheduled
      t.index [:active_job_id], name: :index_solid_queue_jobs_on_active_job_id
      t.index [:scheduled_at], name: :index_solid_queue_jobs_on_scheduled_at
      t.index [:finished_at], name: :index_solid_queue_jobs_on_finished_at
      t.index [:concurrency_key], name: :index_solid_queue_jobs_on_concurrency_key
    end

    create_table :solid_queue_recurring_executions do |t|
      t.string   :job_id, null: false
      t.string   :task_key, null: false
      t.datetime :run_at, null: false
      t.datetime :created_at, null: false

      t.index [:task_key, :run_at], name: :index_solid_queue_recurring_on_task_and_run, unique: true
      t.index [:job_id], name: :index_solid_queue_recurring_on_job_id
    end

    create_table :solid_queue_blocked_executions do |t|
      t.string  :job_id, null: false
      t.string  :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.string  :concurrency_key, null: false
      t.datetime :expires_at, null: false
      t.datetime :created_at, null: false

      t.index [:concurrency_key, :priority, :job_id], name: :index_solid_queue_blocked_on_priority
      t.index [:expires_at], name: :index_solid_queue_blocked_on_expires
      t.index [:job_id], name: :index_solid_queue_blocked_on_job_id, unique: true
    end

    create_table :solid_queue_pauses do |t|
      t.string   :queue_name, null: false
      t.datetime :created_at, null: false

      t.index [:queue_name], name: :index_solid_queue_pauses_on_queue_name, unique: true
    end
  end
end
