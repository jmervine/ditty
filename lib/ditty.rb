$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bson'
require 'mongo_mapper'
#%w( tag post comment ).each do |lib|
%w( tag post ).each do |lib|
  require "ditty/#{lib}"
end
