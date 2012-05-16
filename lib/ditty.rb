$LOAD_PATH.unshift(File.dirname(__FILE__))
%w( mongostore item post comment ).each do |lib|
  require "ditty/#{lib}"
end
