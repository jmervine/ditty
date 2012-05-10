require 'spec_helper'

describe TemplateHelpers do
  before(:all) do
    @helpers = TestTemplateHelpers.new
  end
  let(:helpers) { @helpers }

  describe :post_contents do
    it "should return the contents of a post" do
      helpers.post_contents(File.join(CONFIG["store"], %w{2012 01 file1.md})).should match /Contents for file1/
    end
  end
  describe :post_title do
    it "should return a title string from a file path" do
      helpers.post_title("/foo/bar/my_title.baz").should eq "My Title"
    end
  end
  describe :archive_link do
    it "should return a link to an archive page" do
      helpers.archive_link(File.join(CONFIG["store"], %w{2012 01})).should match /January/
      helpers.archive_link(File.join(CONFIG["store"], %w{2012 01})).should match /a href='\/archive\/2012\/01/
      helpers.archive_link(File.join(CONFIG["store"], %w{2012 01})).should_not match /\.md/
    end
  end
  describe :post_link do
    it "should return a link to a post" do
      helpers.post_link(File.join(CONFIG["store"], %w{ 2012 01 file1.md })).should match /a href='\/post\/2012\/01\/file1/
      helpers.post_link(File.join(CONFIG["store"], %w{ 2012 01 file1.md })).should match /File1/
      helpers.post_link(File.join(CONFIG["store"], %w{ 2012 01 file1.md })).should_not match /\.md/
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
