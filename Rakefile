require 'pp'
require 'mongo'
require 'fileutils'

begin
  require 'vlad'
  Vlad.load :scm => :git, :app => :unicorn
  desc "deploy"
  task "vlad:deploy" => %w[ vlad:update vlad:bundle:install vlad:link_config ]

  namespace :vlad do
    remote_task :link_config, :roles => :app do
      break unless target_host == Rake::RemoteTask.hosts_for(:app).first
      run "ln -s #{deploy_to}/shared/ditty.yml #{deploy_to}/current/config/ditty.yml"
      run "ln -s #{deploy_to}/shared/newrelic.yml #{deploy_to}/current/config/newrelic.yml"
      run "ln -s #{deploy_to}/shared/unicorn.rb #{deploy_to}/current/config/unicorn.rb"
    end
  end
rescue LoadError
  # do nothing
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
  # do nothing
end

desc "start console with env"
task :console do
  ENV['RACK_ENV'] ||= "test"
  exec "irb -r 'pp' -r './dittyapp.rb'"
end

desc "start mongo console"
task :dbconsole do
  ENV['RACK_ENV'] ||= 'test'
  begin
    dbc = YAML.load_file("./config/ditty.yml")[ENV['RACK_ENV']]['database']
    exec "mongo -u #{dbc['username']} -p #{dbc['password']} #{dbc['name']}"
  rescue 
    abort "config/ditty.yml must be present"
  end
end

desc "start server"
task :server do
  ENV['RACK_ENV'] ||= 'development'
  puts "starting with #{ENV['RACK_ENV']} at http://localhost:9001/"
  exec 'unicorn --port 9001 ./config.ru'
end

namespace :unicorn do
  desc "Start unicorn"
  task :start do
    %x{ unicorn -c ./config/unicorn.rb }
  end

  desc "Start unicorn deamonized"
  task :start_d do
    %x{ unicorn -c ./config/unicorn.rb -D }
  end

  desc "Stop unicorn"
  task :stop do
    %x{ kill -QUIT $( cat log/unicorn.pid ) }
  end

  task :stop_f do
    %x{ ps aux | grep unicorn | grep -v grep | awk '{print $1}' | xargs kill -9 }
    %x{ [[ -e log/unicorn.pid ]] && rm log/unicorn.pid }
  end

  desc "Restart unicorn deamonized" 
  task :hup do
    Rake::Task['unicorn:stop'].invoke
    sleep 5
    Rake::Task['unicorn:start_d'].invoke
  end

end

