require 'spec_helper'
#require 'mongo_mapper'
#require './lib/ditty'

describe Ditty::Tag do
  before(:all) do
    build_clean_data
    @tag = Ditty::Tag.new(:tag => 'foo', 
                          :post_id => [ 'foobar' ])
  end
  let(:item) { @tag }

  describe :tag do
    it "should exist" do
      item.tag.should eq "foo"
      item["tag"].should eq "foo"
    end
  end
  describe :save! do
    it "should save" do
      expect { item.save! }.should_not raise_error
    end
    it "should add created_at" do
      item.created_at.should be_a_kind_of Time
    end
    it "should add updated_at" do
      item.updated_at.should be_a_kind_of Time
    end
  end
  describe :count do
    it "should equal :post_id.count" do
      item.count.should eq item.post_id.count
    end
  end
  describe :push_id do
    it "should add a new post_id to :post_id" do
      item.push_id('bazboo').should have(2).items
    end
    it "should not add an existing post_id to :post_id" do
      item.push_id('bazboo').should have(3).items
    end
  end
  describe :has_id? do
    it "should return true if has id" do
      item.has_id?('foobar').should be_true
    end
    it "should return false if does not have id" do
      item.has_id?('fake_id').should be_false
    end
  end
  describe :where do
    it "should find the record just saved" do
      Ditty::Tag.where(:tag => 'foo').first.should be
    end
  end

  describe "Ditty::Tag.add" do
    it "should add a tag and post" do
      post = Ditty::Post.first
      Ditty::Tag.add("add_test", post.id).should be
      Ditty::Tag.where(:tag => "add_test").first.should be
      Ditty::Tag.where(:tag => "add_test").first.post_id.include?(post.id).should be_true
      Ditty::Tag.where(:tag => "add_test").first.post_id.count.should eq 1
    end
    it "should update tag with post if tag doesn't have post" do
      post = Ditty::Post.all[2]
      Ditty::Tag.add("add_test", post.id).should be
      Ditty::Tag.where(:tag => "add_test").first.should be
      Ditty::Tag.where(:tag => "add_test").first.post_id.include?(post.id).should be_true
      Ditty::Tag.where(:tag => "add_test").first.post_id.count.should eq 2
    end
    it "should change nothing if tag exists and has post" do
      post = Ditty::Post.all[2]
      what_tag_was = Ditty::Tag.where(:tag => 'add_test').first
      lambda {
        Ditty::Tag.add("add_test", post.id)
      }.should_not change(Ditty::Tag.where(:tag => 'add_test').first, :post_id)
      Ditty::Tag.add("add_test", post.id).should eq what_tag_was
    end
  end

end


