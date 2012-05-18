require 'spec_helper'
include Ditty # set context

describe Ditty::Item do

  before(:all) do
    @item = Item.new("body" => 'body', "title" => 'title')
  end
  let(:item) { @item }

  describe :load do
    it "should load from a hash" do
      item = Item.load( { "_id" => :id, "title" => "title", "body" => "body", "created_at" => Time.now, "updated_at" => Time.now } )
      item.should be_a_kind_of Ditty::Item
      item.should have_key "_id"
      item.should have_key "title"
      item.should have_key "body"
      item.should have_key "created_at"
      item.should have_key "updated_at"
    end
  end

  describe :body do
    it "should exist" do
      item.body.should eq "body"
      item["body"].should eq "body"
    end
  end
  describe :title do
    it "should exist" do
      item.title.should eq "title"
      item["title"].should eq "title"
    end
  end
  describe :store do
    before do
      @item = Item.new
    end
    it "should raise error on invalid option" do
      expect { @item.store :bad, :whatever }.should raise_error InvalidOptionError
    end
    it "should convert symbol keys to string keys before storing" do
      @item.store(:title, "title test")
      @item.should_not have_key :title
      @item.should have_key "title"
    end
  end

  describe "[ERROR HANDLING]" do
    it "initialization with invalid options should raise error" do
      expect { Item.new( :bad => "option" ) }.should raise_error InvalidOptionError
    end
    it "storing an invalid option should raise error" do
      new_item = Item.new
      expect { new_item[:bad] = "option" }.should raise_error InvalidOptionError
      expect { new_item.store(:bad, "option") }.should raise_error InvalidOptionError
    end
    it "created_at should raise an error when not set" do
      new_item = Item.new
      #expect { new_item.created_at }.should raise_error InvalidOptionError
      new_item.created_at.should be_nil
    end
    it "setting created_at should raise an error" do
      new_item = Item.new
      expect { new_item["created_at"] = Time.now }.should raise_error InvalidOptionError
      expect { new_item.store("created_at", Time.now) }.should raise_error InvalidOptionError
      expect { new_item.created_at = Time.now }.should raise_error NoMethodError
    end
    it "updated_at should raise an error when not set" do
      new_item = Item.new
      #expect { new_item.updated_at }.should raise_error InvalidOptionError
      new_item.updated_at.should be_nil
    end
    it "setting updated_at should raise error" do
      new_item = Item.new
      expect { new_item["updated_at"] = Time.now }.should raise_error InvalidOptionError
      expect { new_item.store("updated_at", Time.now) }.should raise_error InvalidOptionError
      expect { new_item.updated_at = Time.now }.should raise_error NoMethodError
    end
  end
end

