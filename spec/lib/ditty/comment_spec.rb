#require 'spec_helper'

#describe Comment do
  #before(:all) do
    #@item = Comment.new(:post_id => '0', 
                               #:title => "title",
                                #:body => 'body',
                                #:created_by => 'commenter')
  #end
  #let(:item) { @item }

  #describe :post_id do
    #it "should exist" do
      #item.body.should eq "body"
      #item["body"].should eq "body"
    #end
  #end

  #describe :created_by do
    #it "should exist" do
      #item.created_by.should eq "commenter"
      #item["created_by"].should eq "commenter"
    #end
  #end

  #describe :body do
    #it "should exist" do
      #item.body.should eq "body"
      #item["body"].should eq "body"
    #end
  #end
  #describe :title do
    #it "should exist" do
      #item.title.should eq "title"
      #item["title"].should eq "title"
    #end
  #end
  #describe :save! do
    #it "should save" do
      #expect { item.save! }.should_not raise_error
    #end
    #it "should add created_at" do
      #item.created_at.should be_a_kind_of Time
    #end
    #it "should add updated_at" do
      #item.updated_at.should be_a_kind_of Time
    #end
  #end
  #describe :where do
    #it "should find the record just saved" do
      #Comment.where(:title => 'title', :body => 'body').first.should be
    #end
  #end

#end

