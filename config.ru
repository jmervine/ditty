# This file is used by Rack-based servers to start the application.
require './ditty'

ENV['RACK_ENV'] ||= "development"

use Rack::ShowExceptions
use Rack::Static
run Ditty.new
