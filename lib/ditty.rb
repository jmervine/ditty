require 'bson'
require 'mongo_mapper'

%w( tag post ).each do |lib|
  require "ditty/#{lib}"
end

