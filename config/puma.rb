# Puma configuration for Docker
workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count

port ENV.fetch("PORT", 9000)
environment ENV.fetch("RAILS_ENV", "production")

pidfile ENV.fetch("PIDFILE", "tmp/pids/puma.pid")
state_path "tmp/pids/puma.state"

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end

on_worker_shutdown do
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end
