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

  describe :add_tag do
    it "should add a tag" do
      @p1.add_tag("post_spec_one").should be
      @p1.tags.count.should eq 1
      Tag.where(:name => "post_spec_one").count.should eq 1
    end
    it "should not re-add a tag" do
      @p1.add_tag("post_spec_one").should be
      @p1.tags.count.should eq 1
      Tag.where(:name => "post_spec_one").count.should eq 1
    end
    it "should add another tag" do
      @p1.add_tag("post_spec_two").should be
      @p1.tags.count.should eq 2
      Tag.where(:name => "post_spec_two").count.should eq 1
    end
    it "should not create a new tag when adding a tag to a different post" do
      @p2.add_tag("post_spec_one").should be
      @p2.tags.count.should eq 1
      Tag.where(:name => "post_spec_one").count.should eq 1
      Post.find(@p2.id).tag_ids.include?(Tag.where(:name => "post_spec_one").first.id).should be_true
    end
  end

  describe :add_tags do
    it "should add multiple tags" do
      @p1.add_tags( [ "post_spec_three", "post_spec_four", "post_spec_five" ] ).should be
      @p1.tags.count.should eq 5
      Tag.where(:name => "post_spec_three").count.should eq 1
      Tag.where(:name => "post_spec_four").count.should eq 1
      Tag.where(:name => "post_spec_five").count.should eq 1
    end
    it "should only add new tags" do
      @p1.add_tags( [ "post_spec_three", "post_spec_four", "post_spec_five", "post_spec_six" ] ).should be
      @p1.tags.count.should eq 6
      Tag.where(:name => "post_spec_six").count.should eq 1
    end
    it "should not create new tags when adding tags to a different post" do
      @p2.add_tags( [ "post_spec_three", "post_spec_four", "post_spec_five" ] ).should be
      @p2.tags.count.should eq 4
      Tag.where(:name => "post_spec_three").count.should eq 1
      Tag.where(:name => "post_spec_four").count.should eq 1
      Tag.where(:name => "post_spec_five").count.should eq 1
    end
  end

end

