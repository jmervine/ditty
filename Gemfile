source :rubygems

gem 'sinatra'
gem 'rake'
gem 'redcarpet'
gem 'rack-mobile-detect'
gem 'tzinfo'
gem 'rdoc'
gem 'simple_disk_cache', :git => 'https://github.com/jmervine/simple_disk_cache.git'

gem 'haml'

group :newrelic do
  gem 'newrelic_rpm'
end

group :mongo do
  gem 'mongo'
  gem 'bson_ext'
  #gem 'mongo_mapper'
  gem 'mongoid'
end

group :test, :development do
  gem 'rspec'
  gem 'rack-test'
  gem 'travis-lint'
end

group :unicorn do
  gem 'unicorn'
end

group :deployment do
  gem 'vlad'
  gem 'vlad-git'
  gem 'vlad-unicorn'
end

# vim: filetype=ruby
