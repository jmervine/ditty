require 'spec_helper'
require 'tzinfo'

describe Helper::Templates do
  before(:all) do
    build_clean_data
    @helpers = TestHelpersTemplates.new
    @connection = Post.all
    @post_one = Post.first#(:order => :created_at.asc)
    @post_two = Post.last#(:order => :created_at.asc)
  end
  let(:helpers) { @helpers }
  let(:collection) { @collection }
  let(:post_one) { @post_one }
  let(:post_two) { @post_two }

  describe :time_display do
    it "should show created" do
      post = Post.new(:title => "foo")
      post.save!
      helpers.time_display(post).should match Regexp.new(Regexp.escape("<span class='header_time'>Created "))
    end
    it "should show correct timezone per 'settings.timezone'" do
      post = Post.new(:title => "bar")
      post.save!
      expected_time = TZInfo::Timezone.get("America/Los_Angeles").utc_to_local(post.created_at.utc).strftime("%r")
      helpers.time_display(post).should match Regexp.new(expected_time)
    end
    it "should return blank when post is empty" do
      helpers.time_display(Post.new).should eq ""
    end
  end

  describe :post_contents do
    it "should return the body of a post" do
      helpers.post_contents(post_one).should match /^post body/
    end
    it "should return blank when post is empty" do
      helpers.time_display(Post.new).should eq ""
    end
  end

  describe :post_title do
    it "should return the title of a post" do
      helpers.post_title(post_one).should match /^post title/
    end
    it "should return blank when post is empty" do
      helpers.time_display(Post.new).should eq ""
    end
  end

  describe :archive_link do
    it "should return a link to an archive page" do
      helpers.archive_link(2012, 01).should match /January/
      helpers.archive_link(2012, 01).should match /a href='\/2012\/01/
      helpers.archive_link(2012, 1).should match /a href='\/2012\/01/
      helpers.archive_link("2012", "1").should match /a href='\/2012\/01/
      helpers.archive_link("2012", "01").should match /a href='\/2012\/01/
    end
  end

  describe :archive_items do
    before(:all) do
      @archive = helpers.archive_items
    end
    it "should return a hash of all posts" do
      @archive.should have(2).items # top level keys
      @archive[2011].should have(6).items # second level keys
      @archive[2011][05].should have(6).items # thrid level items
    end
    it "top level should be years" do
      @archive.should have(2).items
      @archive.keys.should eq [2012,2011]
    end
    it "second level should be months" do
      @archive[2012].should have(6).items
      @archive[2012].keys.should eq [10,9,8,7,6,5]
    end
    it "third level should be items" do
      @archive[2012][5].should have(6).items
      @archive[2012][5].first.should be_a Post
    end
  end

  describe :archive_list do
    describe "should build an archive list" do
      it "with months as links" do
        (2011..2012).each do |y|
          (5..10).each do |m| 
            str = "/" + y.to_s + "/" + ("%02d" % m )
            helpers.archive_list.should match Regexp.new(Regexp.escape(str))
          end
        end
      end
      it "with items as links" do
        (2011..2012).each do |y|
          (5..10).each do |m| 
            helpers.archive_list.should match Regexp.new("<a href\=\'\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/([a-z0-9\_\-]+)\'\>post title")
          end
        end
      end
    end
  end
  describe :post_link do
    it "should return a link to a post" do
      helpers.post_link(post_one).should match Regexp.new("a href=")
      helpers.post_link(post_one).should match Regexp.new(@post_one['title_path'])
      helpers.post_link(post_one).should match Regexp.new("post title")
    end
  end
  describe :months do
    it "should return an array of months" do
      helpers.months.should be_a_kind_of Array
      helpers.months.count.should eq 12
      helpers.months[5].should eq "june"
    end
  end
end

