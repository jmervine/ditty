require 'bson'
#require 'mongo_mapper'
require 'mongoid'

%w( tag post ).each do |lib|
  require "ditty/#{lib}"
end

