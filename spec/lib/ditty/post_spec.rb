require 'spec_helper'

describe Ditty::Post do
  before(:all) do
    @post = Ditty::Post.new(:title => 'title', 
                            :body => 'body')
  end
  let(:post) { @post }

  describe :initialize do
    it "should exist" do
      post.should be
      post.should be_a_kind_of Ditty::Post
    end
  end
  # other methods tested by item_spec
  #
end

