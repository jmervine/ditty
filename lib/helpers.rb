$LOAD_PATH.unshift(File.dirname(__FILE__))
%w( templates application ).each do |lib|
  require "helpers/#{lib}"
end

