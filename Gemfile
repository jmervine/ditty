source :rubygems

gem 'sinatra'
gem 'rake'
gem 'redcarpet'
gem 'rack-mobile-detect'
gem 'tzinfo'
gem 'rdoc'
gem 'diskcached'

gem 'haml'

group :newrelic do
  gem 'newrelic_rpm'
end

group :mongo do
  gem 'mongo'
  gem 'bson_ext'
  gem 'mongoid'
  gem 'will_paginate'
end

group :test, :development do
  gem 'rspec'
  gem 'rack-test'
  gem 'travis-lint'
  gem 'simplecov', :require => false
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
