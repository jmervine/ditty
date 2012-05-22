require 'spec_helper'

describe Ditty::Post do
  before(:all) do
    @post = Ditty::Post.new(:title => 'title', 
                            :body => 'body')
  end
  let(:item) { @post }

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
  describe :where do
    it "should find the record just saved" do
      Ditty::Post.where(:title => 'title', :body => 'body').first.should be
    end
  end

end

