source :rubygems

gem 'sinatra'
gem 'rake'
gem 'redcarpet'
gem 'rack-mobile-detect'
gem 'tzinfo'

gem 'sinatra-authentication'
gem 'haml' # for sinatra-auth
gem 'rack-flash'

gem 'haml'

gem 'newrelic_rpm'

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
  gem 'rdoc'
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
