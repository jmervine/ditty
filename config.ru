# This file is used by Rack-based servers to start the application.
require './dittyapp'
require 'rack/mobile-detect'

ENV['RACK_ENV'] ||= "production"

begin
  if File.exists? "./config/newrelic.yml"
    require 'newrelic_rpm'
    NewRelic::Agent.after_fork(:force_reconnect => true)
  end
rescue LoadError
  # proceed without NewRelic
end

use Rack::ShowExceptions
use Rack::Static
use Rack::MobileDetect

run DittyApp.new
