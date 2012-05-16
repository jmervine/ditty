#!/usr/bin/env ruby
require 'pp'
require 'mongo'
conf = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config", "ditty.yml"))
config = begin conf["default"].merge!(conf["test"]) rescue conf["default"] end

connection = Mongo::Connection.new.db(config['database'])[config['table']]
connection.remove # clean database
# build posts
(2011..2012).each do |year|
  (5..10).each do |month|
    (5..10).each do |day|
      time = Time.new(year, month, day, 12)
      connection.insert( { "created_at"  => time, 
                            "updated_at"  => time, 
                            "title"       => "post title - #{year}.#{month}.#{day}",
                            "body"        => "post body - #{year}.#{month}.#{day}" } )
      #puts "creating: test post for #{time}"
    end
  end
end

puts ""
puts "seeded #{connection.count} test items like this one..."
puts ""
pp connection.find.to_a.last
puts ""

