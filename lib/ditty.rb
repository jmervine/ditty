require 'bson'

%w( tag post ).each do |lib|
  require "ditty/#{lib}"
end

