require 'spec_helper'

describe Tag do
  before(:all) do
    build_clean_data
    @p1 = Post.create(:title => "Post Spec One", :body => "Post Spec body one.")
    @p1.tags.create(:name => "tag_spec_one")
    @t1 = Tag.where(:name => "tag_spec_one").first
  end
  describe "create through Post" do
    it "should create a tag through a post" do
      Tag.where(:name => "tag_spec_one").count.should eq 1
    end
    it "should have post that created it" do
      @t1.posts.include?(@p1).should be_true
    end
    it "should be in post that creaeted it" do
      @p1.tags.include?(@t1).should be_true
    end
  end
end

