require "bundler/vlad"
set :application, "ditty"
set :domain, "blog.mervine.net"
set :deploy_to, "/home/jmervine/ditty"
set :repository, 'git://github.com/jmervine/ditty.git'
set :bundle_without,  [:development, :test, :deployment, :import]
