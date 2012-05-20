require 'spec_helper'
#require './lib/ditty'

describe Ditty::MongoStore do
  before(:all) do
    # TODO: pull from ditty.yml
    #Ditty::Item.data_store = Ditty::MongoStore.new({ 
       #"name" => "ditty_test", 
       #"table" => "ditty_test", 
       #"username" => "test", 
       #"password" => "test"
     #})
    Ditty::Item.data_store = Ditty::MongoStore.new(CONFIG['database'])

    @item_one = Ditty::Item.new( { "title" => "title one", "body" => "body one" } )
    @item_two = Ditty::Item.new( { "title" => "title two", "body" => "body two" } )
  end
  let(:store) { Ditty::Item.data_store }
  let(:item_one)   { @item_one }
  let(:item_two)   { @item_two }

  describe :initialize do
    it "should be initialized" do
      store.should be 
    end
  end
  describe :name do
    it "should be set" do
      store.name.should eq "ditty_test"
    end
    it "should not set" do
      expect { store.name = "test_set" }.should raise_error NoMethodError
    end
  end
  describe :table do
    it "should be set" do
      store.table.should eq "ditty_test"
    end
    it "should not set" do
      expect { store.table = "test_set" }.should raise_error NoMethodError
    end
  end
  describe :collection do
    it "should be a mongo collection" do
      store.collection.should be_a_kind_of Mongo::Collection
    end
  end

  describe :remove, "without params (via :method_missing)" do
    it "should remove all records" do
      store.remove # start empty
      store.count.should eq 0
    end
  end

  describe :find, "when empty" do
    it "should return an empty Array" do
      store.find.should be_empty
    end
  end

  describe "[calls via Ditty::MongoStore object]" do

    describe :insert, "(via :method_missing)" do
      it "should create a new record" do
        store.insert(item_one).should be
        store.count.should eq 1
      end
    end

    describe :find, "when has records" do
      it "should not return an empty Array" do
        store.find.should_not be_empty
      end
      it "should return an Array of Hash objects" do
        store.find.first.should be_a_kind_of Hash
      end
      it "should have an _id" do
        store.find.first["_id"].should be
      end
      it "should have a title" do
        store.find.first["title"].should eq "title one"
      end
      it "should have a body" do
        store.find.first["body"].should eq "body one"
      end
    end

    describe :update, "(via :method_missing)" do
      it "should update the record" do
        record = store.find.first
        record["title"] = "title one updated"
        store.update( { "_id" => record["_id"] }, record )
        store.find.first["title"].should eq "title one updated"
      end
    end

    describe :remove, "specifc record (via :method_missing)" do
      it "should remove the specified record" do
        record = store.find.first
        store.remove( { "_id" => record["_id"] } )
        store.count.should eq 0
      end
    end

  end

  describe "[calls via Ditty::Item object]" do
    describe "start empty" do
      it "should be empty" do
        store.remove
        store.count.should be 0
      end
    end
    describe :insert do
      it "should create a new record" do
        item_two.insert.should be
        store.count.should eq 1
      end
      it "should have created_at" do
        item_two.created_at.should be
        item_two.created_at.should be_a_kind_of Time
      end
      it "should have updated_at" do
        item_two.updated_at.should be
        item_two.updated_at.should be_a_kind_of Time
      end
      it "updated_at should be created_at" do
        item_two.updated_at.should be item_two.created_at
      end
    end

    describe :find, "(via Ditty::Item.load)" do
      before(:all) do
        @id = store.find.first["_id"]
        @item_three = Ditty::Item.load(@id)
      end
      it "should return a Ditty::Item" do
        @item_three.should be_a_kind_of Ditty::Item
      end
      it "should have an _id" do
        @item_three.id.should eq @id
      end
      it "should have a title" do
        @item_three.title.should eq "title two"
      end
      it "should have a body" do
        @item_three.body.should eq "body two"
      end
      it "should have created_at" do
        @item_three.created_at.should be_a_kind_of Time
      end
      it "should have updated_at" do
        @item_three.updated_at.should be_a_kind_of Time
      end
      it "updated_at should be created_at" do
        @item_three.updated_at.should eq @item_three.created_at
      end
    end

    describe :update do
      before(:all) do
        @id = store.find.first["_id"]
        @item_three = Ditty::Item.load(@id)
      end
      it "should update the item" do
        @item_three.title = "title three updated"
        @item_three.title.should eq "title three updated"
        lambda {
          @item_three.update
        }.should change(@item_three, :updated_at)
        updated_item = Ditty::Item.load(@id)
        updated_item.title.should eq "title three updated"
        updated_item.updated_at.should_not eq updated_item.created_at
        updated_item.updated_at.should be > updated_item.created_at
      end
    end

    describe :remove, "specifc record (via :method_missing)" do
      before(:all) do
        @id = store.find.first["_id"]
        @item_three = Ditty::Item.load(@id)
      end
      it "should remove the specified record" do
        @item_three.remove
        expect { 
          Ditty::Item.load(@id)
        }.should raise_error
      end
      it "should remove protected keys" do
        @item_three.should_not have_key "_id"
        @item_three.should_not have_key "created_at"
        @item_three.should_not have_key "updated_at"
      end
    end

  end

end
