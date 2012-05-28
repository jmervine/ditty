#!/usr/bin/env ruby
require 'pp'
require './dittyapp.rb'

puts "Migraging 'Post':"
puts " "
puts "- Getting rid of duplicate titles. "
puts "- Ensuring title_path "
print "  "
Post.all.each do |post|
  if dups = Post.where(:title => post.title) and dups.count > 1
    dups.each do |dup|
      dup.title << " - Part #{index}"
      if dup.save!
        print "D"
      else
        print "E"
      end
    end
  end

  if post.save! and !( post.title_path.nil? or post.title_path.blank? )
    print "S"
  else 
    print "-"
  end
end
puts " "
