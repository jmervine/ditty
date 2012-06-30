# This file is used by Rack-based servers to start the application.
ENV['RACK_ENV'] ||= "production"

require './dittyapp'
require 'rack/mobile-detect'
#require 'rack-flash'

use Rack::Session::Cookie
use Rack::ShowExceptions
use Rack::Static
#use Rack::Flash
use Rack::MobileDetect

run DittyApp.new
