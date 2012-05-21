require "bundler/vlad"
set :application, "ditty"
set :domain, "blog.mervine.net"
set :deploy_to, "/home/jmervine/ditty"
set :repository, 'git://github.com/jmervine/ditty.git'

# bundler
set :bundle_without,  [:development, :test, :deployment]

# unicorn
set :unicorn_pid, "/home/jmervine/ditty/shared/unicorn.pid"
