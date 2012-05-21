require 'spec_helper'

describe Ditty::Comment do
  before(:all) do
    @comment = Ditty::Comment.new(:post_id => '0', 
                                  :body => 'body',
                                  :created_by => 'commenter')
  end
  let(:comment) { @comment }

  describe :post_id do
    it "should exist" do
      comment.body.should eq "body"
      comment["body"].should eq "body"
    end
  end

  describe :created_by do
    it "should exist" do
      comment.created_by.should eq "commenter"
      comment["created_by"].should eq "commenter"
    end
  end

  # other methods tested by item_spec
end

