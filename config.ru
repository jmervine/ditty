# This file is used by Rack-based servers to start the application.
require './dittyapp'
#require 'rack/mobile-detect'

ENV['RACK_ENV'] ||= "development"

use Rack::ShowExceptions
#use Rack::Static
use Rack::MobileDetect
run DittyApp.new
