require 'spec_helper'

describe HelpersTemplates do
  before(:all) do
    build_clean_data
    @helpers = TestHelpersTemplates.new
    @collection = Mongo::Connection.new.db(CONFIG['database']['name'])[CONFIG['database']['table']]
    @post_one = @collection.find.to_a.first
    @post_two = @collection.find.to_a.last
    Ditty::Item.data_store = @collection
  end
  let(:helpers) { @helpers }
  let(:collection) { @collection }
  let(:post_one) { Ditty::Item.load(@post_one) }
  let(:post_two) { Ditty::Item.load(@post_two) }

  describe :time_display do
    it "should be" do
      helpers.time_display(post_one).should match Regexp.new(Regexp.escape("<span class='header_time'>Created "))
    end
  end

  describe :post_contents do
    it "should return the body of a post" do
      helpers.post_contents(post_one).should match /^post body/
    end
  end
  describe :post_title do
    it "should return the title of a post" do
      helpers.post_title(post_one).should match /^post title/
    end
  end
  describe :archive_link do
    it "should return a link to an archive page" do
      helpers.archive_link(2012, 01).should match /January/
      helpers.archive_link(2012, 01).should match /a href='\/archive\/2012\/01/
      helpers.archive_link(2012, 1).should match /a href='\/archive\/2012\/01/
      helpers.archive_link("2012", "1").should match /a href='\/archive\/2012\/01/
      helpers.archive_link("2012", "01").should match /a href='\/archive\/2012\/01/
    end
  end
  describe :archive_items do
    it "should return a hash of all posts" do
      helpers.archive_items.should have(2).items # top level keys
      helpers.archive_items.shift.last.should have(6).items # second level keys
      helpers.archive_items.shift.last.shift.last.should have(6).items # thrid level items
    end
    it "top level should be years" do
      helpers.archive_items.should have(2).items
      helpers.archive_items.keys.should eq [2012,2011]
    end
    it "second level should be months" do
      helpers.archive_items[2012].should have(6).items
      helpers.archive_items[2012].keys.should eq [10,9,8,7,6,5]
    end
    it "third level should be items" do
      helpers.archive_items[2012][5].should have(6).items
      helpers.archive_items[2012][5].first.should be_a Ditty::Post
    end
  end
  describe :archive_nav_list do
    describe "should build an archive list" do
      it "with years as links" do
        helpers.archive_nav_list.should match /2011<\/a>/
        helpers.archive_nav_list.should match /2012<\/a>/
      end
      it "with months as links" do
        (2011..2012).each do |y|
          (5..10).each do |m| 
            str = "/archive/" + y.to_s + "/" + ("%02d" % m )
            helpers.archive_nav_list.should match Regexp.new(Regexp.escape(str))
          end
        end
      end
      it "without items" do
        (2011..2012).each do |y|
          (5..10).each do |m| 
            helpers.archive_nav_list.should_not match Regexp.new("\/post\/([a-z0-9]+)\'\>post title")
          end
        end
      end
    end
  end
  describe :archive_list do
    describe "should build an archive list" do
      it "with years as links" do
        helpers.archive_nav_list.should match /2011<\/a>/
        helpers.archive_nav_list.should match /2012<\/a>/
      end
      it "with months as links" do
        (2011..2012).each do |y|
          (5..10).each do |m| 
            str = "/archive/" + y.to_s + "/" + ("%02d" % m )
            helpers.archive_list.should match Regexp.new(Regexp.escape(str))
          end
        end
      end
      it "with items as links" do
        (2011..2012).each do |y|
          (5..10).each do |m| 
            helpers.archive_list.should match Regexp.new("\/post\/([a-z0-9]+)\'\>post title")
          end
        end
      end
    end
  end
  describe :post_link do
    it "should return a link to a post" do
      helpers.post_link(post_one).should match Regexp.new("a href=")
      helpers.post_link(post_one).should match Regexp.new(@post_one["_id"].to_s)
      helpers.post_link(post_one).should match Regexp.new("post title")
    end
    it "should return a link to a post by title upon request" do
      helpers.post_link(post_one, true).should match Regexp.new("a href=")
      helpers.post_link(post_one, true).should match Regexp.new("post%20title")
      helpers.post_link(post_one, true).should match Regexp.new("post title")
    end
  end
  describe :months do
    it "should return an array of months" do
      helpers.months.should be_a_kind_of Array
      helpers.months.count.should eq 12
      helpers.months[5].should eq "june"
    end
  end

  describe :latest do
    it "should return the _n_ most recent posts" do
      helpers.latest.should have(25).items
      helpers.latest(10).should have(10).items
    end
    it "should return the most recent items" do
      helpers.latest.first.should eq (collection.find.to_a.sort_by { |i| i["created_at"] }).reverse.first
    end
  end

end

