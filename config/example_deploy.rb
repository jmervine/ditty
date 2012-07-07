require "bundler/vlad"
set :repository, 'SET ME'

# bundler
set :bundle_without,  [:development, :test, :deployment]

# unicorn

task :ditty do
  set :domain, "SET ME"
  set :application, "ditty"
  set :deploy_to, "~/ditty"
  set :unicorn_pid, "#{deploy_to}/shared/log/unicorn.pid"
  set :unicorn_command, "cd /#{deploy_to}/current && RACK_ENV=production bundle exec unicorn"
end

