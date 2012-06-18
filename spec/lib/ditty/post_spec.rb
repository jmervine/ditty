require 'spec_helper'

describe Post do
  before(:all) do
    build_clean_data
    @p1 = Post.create(:title => "Post Spec One", :body => "Post Spec body one.")
    @p2 = Post.create(:title => "Post Spec Two", :body => "Post Spec body two.")
  end

  describe :create do
    it "should create a Post" do
      @p1.should be
    end
  end

  describe :title do
    it "should have a title" do
      @p1.title.should eq "Post Spec One"
    end
  end

  describe :body do
    it "should have a body" do
      @p1.body.should eq "Post Spec body one."
    end
  end

  describe :associate_or_create_tag do
    it "should create a tag that doesn't exist" do
      @p1.associate_or_create_tag("non_existant_tag").should be
      Tag.where(:name => "non_existant_tag").count.should eq 1
    end
    it "should associate the new tag with the post that created it" do
      tag = Tag.where(:name => "non_existant_tag").first
      @p1.tags.include?(tag).should be_true
    end
    it "should associate the post with the new tag" do
      Tag.where(:name => "non_existant_tag").first.posts.include?(@p1).should be_true
    end
    it "should not create a tag that does exist" do
      @p2.associate_or_create_tag("non_existant_tag").should be
      Tag.where(:name => "non_existant_tag").count.should eq 1
    end
    it "should associate the existing tag with the post that tried to created it" do
      @p2.tags.include?(Tag.where(:name => "non_existant_tag").first).should be_true
    end
    it "should associate the post with the existing tag" do
      Tag.where(:name => "non_existant_tag").first.posts.include?(@p2).should be_true
    end
  end

  describe "before_create -> create_title_path" do
    it "should create title path" do
      post = Post.create(:title => "some% funk! tit@le", :body => "body")
      post.title_path.should match /[0-9]{4}\/[0-9]{2}\/[0-9]{2}\/some_funk_title$/
    end
  end

  describe "before_update -> update_title_path" do
    it "should update title path" do
      post = Post.first
      post.title = "another' some% funk! tit@le"
      post.save!
      post.title_path.should match /[0-9]{4}\/[0-9]{2}\/[0-9]{2}\/another_some_funk_title$/
    end
  end

end

