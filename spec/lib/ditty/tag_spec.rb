require 'spec_helper'

describe Tag do
  before(:all) do
    build_clean_data
    @p1 = Post.create(:title => "Post Spec One", :body => "Post Spec body one.")
    @p1.tags.create(:name => "tag_spec_one")
    @t1 = @p1.tags[0]
    @p1.tags.create(:name => "tag_spec_two")
    @t2 = @p1.tags[1]
    @p2 = Post.create(:title => "Post Spec Two", :body => "Post Spec body two.")
    @p2.tag_ids.push @t1.id
    @p2.tag_ids.push @t2.id
    @p2.save!
  end
  describe "create through Post" do
    it "should create a tag through a post" do
      Tag.where(:name => "tag_spec_one").count.should eq 1
    end
  end
  describe :posts do
    it "should list all posts that are associated with the tag" do
      @t1.posts.count.should eq 2
      @t1.posts.include?(@p1).should be_true
      Post.where(:tag_ids => @t1.id).count.should eq 2
    end
  end
  describe :destroy do
    it "should remove the tag and it's reference from all posts" do
      t_id = @t1.id
      @t1.destroy.should be
      Tag.find(t_id).should be_nil 
      Post.where(:tag_ids => t_id).count.should eq 0
    end
  end
end


