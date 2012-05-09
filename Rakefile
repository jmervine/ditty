require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

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

  desc "Restart unicorn deamonized" 
  task :hup do
    Rake::Task['unicorn:stop'].invoke
    Rake::Task['unicorn:start_d'].invoke
  end

end
