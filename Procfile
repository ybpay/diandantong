#web: bundle exec puma -e production -b tcp://0.0.0.0:9000
web: export RUBY_GC_HEAP_INIT_SLOTS=2000000; export RUBY_GC_HEAP_FREE_SLOTS=4096; export RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=10; export RUBY_GC_MALLOC_LIMIT=16777216; export RUBY_GC_MALLOC_LIMIT_MAX=33554432; export RUBY_GC_OLDMALLOC_LIMIT=268435456; export RUBY_GC_OLDMALLOC_LIMIT_MAX=536870912; bundle exec unicorn_rails -p 9000 -c config/unicorn.rb -E production
sidekiq: bundle exec sidekiq -C config/sidekiq.yml -e production -L log/sidekiq.log
pubsub: bundle exec rackup ./private_pub.ru -s thin -E production