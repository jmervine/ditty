# This file is used by Rack-based servers to start the application.
ENV['RACK_ENV'] ||= "production"

require './dittyapp'
require 'rack/mobile-detect'

# TODO: import from config file?
secret_string = if File.exists?(File.join(File.dirname(__FILE__),"config","session_secret.txt"))
                  File.read(File.join(File.dirname(__FILE__), "config", "session_secret.txt"))
                else
                  "#{Time.now.to_s+File.dirname(__FILE__)+`hostname`.strip}" # less secure, but should work
                  # warning, this method will reset all session cookies on server restarted
                end
puts secret_string
use Rack::Session::Cookie, :secret => secret_string
use Rack::ShowExceptions
use Rack::Static
use Rack::Flash
use Rack::MobileDetect

run DittyApp.new
