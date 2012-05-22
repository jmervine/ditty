require 'spec_helper'

describe Ditty::Tag do
  before(:all) do
    Ditty::Tag.where(:tag => 'foo').first.destroy
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
  #describe :title do
    #it "should exist" do
      #item.title.should eq "title"
      #item["title"].should eq "title"
    #end
  #end
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
  describe :push do
    it "should add a new post_id to :post_id" do
      item.push('bazboo').should have(2).items
    end
    it "should not add an existing post_id to :post_id" do
      item.push('bazboo').should have(2).items
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

end


