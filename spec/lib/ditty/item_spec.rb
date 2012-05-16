require 'spec_helper'

describe Ditty::Item do
  before(:all) do
    @item = Ditty::Item.new("body" => 'body', "title" => 'title')
  end
  let(:item) { @item }

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

  describe "[ERROR HANDLING]" do
    it "initialization with invalid options should raise error" do
      expect { Ditty::Item.new( :bad => "option" ) }.should raise_error Ditty::InvalidOptionError
    end
    it "storing an invalid option should raise error" do
      new_item = Ditty::Item.new
      expect { new_item[:bad] = "option" }.should raise_error Ditty::InvalidOptionError
      expect { new_item.store(:bad, "option") }.should raise_error Ditty::InvalidOptionError
    end
    it "created_at should raise an error when not set" do
      new_item = Ditty::Item.new
      expect { new_item.created_at }.should raise_error Ditty::InvalidOptionError
    end
    it "setting created_at should raise an error" do
      new_item = Ditty::Item.new
      expect { new_item["created_at"] = Time.now }.should raise_error Ditty::InvalidOptionError
      expect { new_item.store("created_at", Time.now) }.should raise_error Ditty::InvalidOptionError
      expect { new_item.created_at = Time.now }.should raise_error NoMethodError
    end
    it "updated_at should raise an error when not set" do
      new_item = Ditty::Item.new
      expect { new_item.updated_at }.should raise_error Ditty::InvalidOptionError
    end
    it "setting updated_at should raise error" do
      new_item = Ditty::Item.new
      expect { new_item["updated_at"] = Time.now }.should raise_error Ditty::InvalidOptionError
      expect { new_item.store("updated_at", Time.now) }.should raise_error Ditty::InvalidOptionError
      expect { new_item.updated_at = Time.now }.should raise_error NoMethodError
    end
  end
end

