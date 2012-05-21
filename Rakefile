require 'pp'
require 'mongo'
require 'fileutils'

begin
  require 'vlad'
  Vlad.load :scm => :git, :app => :unicorn
  desc "deploy"
  task "vlad:deploy" => %w[
      vlad:update vlad:bundle:install
  ]
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
  end

  desc "Restart unicorn deamonized" 
  task :hup do
    Rake::Task['unicorn:stop'].invoke
    sleep 5
    Rake::Task['unicorn:start_d'].invoke
  end

end

