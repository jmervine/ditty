$LOAD_PATH.unshift(File.dirname(__FILE__))
%w( templates application configure ).each do |lib|
  require "helpers/#{lib}"
end
module Helper

end
