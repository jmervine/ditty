require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

desc "Start unicorn"
task :unicorn do
  %x{ unicorn -c ./config/unicorn.rb }
end

desc "Start unicorn deamonized"
task :unicorn_d do
  %x{ unicorn -c ./config/unicorn.rb -D }
end
