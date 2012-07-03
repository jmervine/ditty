# This file is used by Rack-based servers to start the application.
ENV['RACK_ENV'] ||= "production"

require './dittyapp'
require 'rack/mobile-detect'
#require 'rack-flash'

require 'newrelic_rpm'
NewRelic::Agent.after_fork(:force_reconnect => true)

use Rack::Session::Cookie

begin
  if File.exists? "./config/newrelic.yml"
    require 'newrelic_rpm'
    NewRelic::Agent.after_fork(:force_reconnect => true)
  end
rescue LoadError
  # proceed without NewRelic
end

>>>>>>> master
use Rack::ShowExceptions
use Rack::Static
#use Rack::Flash
use Rack::MobileDetect

run DittyApp.new

