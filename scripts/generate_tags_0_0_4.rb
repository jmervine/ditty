#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), "..", "dittyapp.rb")

unless ENV['RACK_ENV']
  puts "RACK_ENV is required"
  exit 1 
end

@tags = %w{ ruby rspec nginx rake tumblr parenting bash iphone kids android la_ruby_conf rails database mysql aws sinatra rack mobile vim }

Post.all.each do |post|
  tags = []
  @tags.each do |tag|
    if post.title.downcase =~ Regexp.new(tag)
      tags.push tag
    end
  end
  puts "skipping #{post.title}, no tags to add" if tags.empty?
  puts "adding tags #{post.title}: #{tags.join(", ")}" unless tags.empty?
  post.add_tags(tags) unless tags.empty?
end
