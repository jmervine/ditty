$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mongo_mapper'

%w( item post comment ).each do |lib|
  require "ditty/#{lib}"
end
