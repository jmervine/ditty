require 'bson'
#require 'mongo_mapper'
require 'mongoid'

#Dir["./lib/ditty/*.rb"].each do |lib|
  #require lib
#end
%w( tag post comment mongoid_user ).each do |lib|
  require "ditty/#{lib}"
end

#require 'monkey-patches/sinatra-authentication'
