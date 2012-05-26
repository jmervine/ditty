#!/usr/bin/env ruby
require 'mongo'
require 'pp'

unless ENV['RACK_ENV']
  puts "RACK_ENV is required"
  exit 1 
end
# import configurations
@db_conf = YAML.load_file( File.join(File.dirname(__FILE__), "..", "config", "ditty.yml") )[ENV['RACK_ENV']]['database']

# create database connection
@connection = Mongo::Connection.new
@connection.add_auth(@db_conf['name'], @db_conf['username'], @db_conf['password'])

@database   = @connection[@db_conf['name']]

# test auth
#unless @database.

# Moving from 'ditty.<obj>s' to '<obj>s'
#collections = %w{ posts tags }
collections = %w{ posts }

collections.each do |col_name|

  old_col_name = "ditty."+col_name
  new_col_name = col_name
  
  old_collection = @database.collection(old_col_name)
  new_collection = @database.collection(new_col_name)

  begin
    # migrate!
    puts "Migraging '#{old_col_name}':"
    puts " "
    print "  "
    old_collection.find.each do |item|
      if new_collection.insert item
        print "+"
      else
        print "-"
      end
    end
    puts " "
    puts %{
  Report for '#{old_col_name}' -> '#{new_col_name}':
   - old: #{old_collection.count}
   - new: #{new_collection.count}
    }
  rescue Exception => e
    pp e
    puts "Collection '#{old_col_name}' is empty, skipping!"
  end

end

# create indexs on new collection
if @database.collection('posts').create_index("title")
  puts "created index for title on posts"
else
  puts "couldn't create index for title on posts"
end

if @database.collection('tags').create_index("name")
  puts "created index for name on tags"
else
  puts "couldn't create index for name on tags"
end

