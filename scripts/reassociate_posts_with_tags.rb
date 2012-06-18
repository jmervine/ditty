#!/usr/bin/env ruby
require 'pp'

ENV['RACK_ENV']||="production"
require File.join( File.dirname(__FILE__), "..", "dittyapp" )

posts = Post.all.to_a
tags  = Tag.all.to_a

puts "#{Post.count} to update"

Post.destroy_all
Tag.destroy_all

posts.each do |post|
  new = Post.create! do |doc|
    doc.created_at  = post.created_at
    doc.updated_at  = post.updated_at
    doc.title       = post.title
    #doc.title_path  = post.title_path
    doc.body        = post.body
  end
  post.tag_ids.each do |tag_id|
    #doc.tags.create(name: Tag.find(tag_id).name)
    new.associate_or_create_tag( (tags.select { |t| t._id == tag_id } ).first.name )
  end
end

puts "#{Post.count} updated"
