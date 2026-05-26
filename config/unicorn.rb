# Unicorn configuration for Docker
# Based on original config with dynamic paths

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)

working_directory = ENV.fetch("RAILS_ROOT", "/app")

listen working_directory + "/tmp/.unicorn.sock", :backlog => 64
listen 9000, :tcp_nopush => true

timeout 30

pid working_directory + "/tmp/pids/unicorn.pid"

stderr_path working_directory + "/log/unicorn.stderr.log"
stdout_path working_directory + "/log/unicorn.stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

check_client_connection false

run_once = true

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    if ActiveRecord::Base.connection_proxy.respond_to?(:instance_variable_get)
      ActiveRecord::Base.connection_proxy.instance_variable_get(:@shards).each do |shard, connection_pool|
        connection_pool.disconnect!
      end rescue nil
    end
    ActiveRecord::Base.connection.disconnect!
  end

  if run_once
    run_once = false
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    if ActiveRecord::Base.connection_proxy.respond_to?(:instance_variable_get)
      ActiveRecord::Base.connection_proxy.instance_variable_get(:@shards).each do |shard, connection_pool|
        connection_pool.clear_reloadable_connections!
      end rescue nil
    end
  end
end
