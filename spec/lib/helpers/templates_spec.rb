require 'spec_helper'

describe HelpersTemplates do
  before(:all) do
    build_clean_data
    @helpers = TestHelpersTemplates.new
    @collection = Mongo::Connection.new.db(CONFIG['database'])[CONFIG['table']]
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
      helpers.time_display(post_one).should match Regexp.new(Regexp.escape("<span class='header_time'>Created on "))
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
  describe :archive_list do
    describe "should build an archive list" do
      it "with years" do
        helpers.archive_list.should match /2011/
        helpers.archive_list.should match /2012/
      end
      it "with months" do
        (2011..2012).each do |y|
          (5..10).each do |m| 
            str = "/archive/" + y.to_s + "/" + ("%02d" % m )
            helpers.archive_list.should match Regexp.new(Regexp.escape(str))
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
      helpers.latest.should have(5).items
      helpers.latest(10).should have(10).items
    end
    it "should return the most recent items" do
      helpers.latest.first.should eq (collection.find.to_a.sort_by { |i| i["created_at"] }).reverse.first
    end
  end
end

