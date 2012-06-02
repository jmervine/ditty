require 'spec_helper'

describe DittyApp, "< Sinatra::Application" do
  before(:all) do
    build_clean_data
  end

  describe "General Tests [without auth]" do
    pages = {
      "get" => {
        "/post" => "/post"
      },
      "post" => {
        "/post" => "/post",
        "/post/preview" => "/post/preview"
      }
    }

    pages.each do |method_name, method_pages|
      method_pages.each do |page_name, page_path|
        describe "#{method_name.upcase} #{page_name}" do
          before(:all) do
            if method_name == "post"
              post page_path
            elsif method_name == "get"
              get page_path
            end
          end
          it "should reject" do
            HelpersApplication.stub(:authorized?).and_return false
            last_response.status.should eq 401
          end
        end
      end
    end
  end

  describe "General Tests [with auth]" do
    pages = {
      "get" => {
        "/" => "/",
        "/post" => "/post",
        "/archive" => "/archive",
        "/:year" => "/2012",
        "/:year/:month" => "/2012/05",
        "/:year/:month/:day" => "/2012/05/05",
        "/tag" => "/tag",
        "/tag/:tag" => "/tag/tag_one"
      }    
    }

    pages.each do |method_name, method_pages|
      method_pages.each do |page_name, page_path|
        describe "#{method_name.upcase} #{page_name}" do
          authorize "test", "test"
          before(:all) do
            authorize 'test', 'test'
            if method_name == "post"
              post page_path
            elsif method_name == "get"
              get page_path
            end
          end
          it "should accept" do
            last_response.should be_ok
          end
        end
      end
    end
  end

  describe "Less General Tests" do

    describe "GET /login" do
      before(:all) do
        authorize 'test', 'test'
        get "/login"
      end
      it "should redirect to the home page" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org/"
      end
    end

    describe "GET /:title_path" do
      before(:all) do
        @post = Post.first
        get "#{@post.title_path}" # find a real post via it's id
      end
      it "should load post" do
        last_response.should be_ok
      end
    end

    describe "GET /post/:id/edit [without auth]" do
      before(:all) do
        HelpersApplication.stub(:authorized?).and_return false
        get "/post/#{Post.first.id.to_s}/edit" # find a real post via it's id
      end
      it "should reject" do
        last_response.status.should eq 401
      end
    end

    describe "GET /post/:id/edit [with auth]" do
      before(:all) do
        authorize 'test', 'test'
        HelpersApplication.stub(:authorized?).and_return true
        get "/post/#{Post.first.id.to_s}/edit" # find a real post via it's id
      end
      it "should load post edit form" do
        last_response.should be_ok
      end
    end

    describe "POST /post/:id/preview [without auth]" do
      before(:all) do
        HelpersApplication.stub(:authorized?).and_return false
        post "/post/#{Post.first.id.to_s}/preview", :post => { "title" => "foo", "body" => "bar", "tags" => "boo" }
      end
      it "should reject" do
        last_response.status.should eq 401
      end
    end

    describe "POST /post/:id/preview [with auth]" do
      before(:all) do
        authorize 'test', 'test'
        HelpersApplication.stub(:authorized?).and_return true
        post "/post/#{Post.first.id.to_s}/preview", :post => { "title" => "foo", "body" => "bar", "tags" => "boo" }
      end
      it "should load post preivew page" do
        last_response.should be_ok
      end
    end

    describe "GET /bad/path" do
      before(:all) do
        get "/bad/path"
      end
      it "should redirect" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org/"
      end
    end

    describe "POST /bad/path" do
      before(:all) do
        post "/bad/path"
      end
      it "should redirect home" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org/"
      end
    end

    describe "BAD /bad/path" do
      before(:all) do
        put "/bad/path"
      end
      it "should redirect home" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org/"
      end
    end

    describe "POST /post" do
      before(:all) do
        authorize "test", "test"
        HelpersApplication.stub(:authorized?).and_return true
        post "/post", :post => { "title" => "create test title", "body" => "create test body", "tags" => "app_tag_one app_tag_two" }
      end
      it "should have added to the data store" do
        Post.where(:title => "create test title").should be
      end
      it "should load created post" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org#{Post.where(:title => "create test title").first.title_path}"
      end
    end

    describe "POST /post/:id" do
      before(:all) do
        authorize "test", "test"
        HelpersApplication.stub(:authorized?).and_return true
        @update_id = Post.last.id.to_s
        post "/post/#{@update_id}", :post => { 
            "title" => "updated test title", 
            "body" => "updated test body", 
            "tags" => "new_post_tag_one new_post_tag_two" }
      end
      it "should have added to the data store" do
        Post.find(@update_id).should be
      end
      it "should have changed updated_at" do
        Post.find(@update_id).title.should eq "updated test title"
      end
      it "should load the updated post" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org#{Post.find(@update_id).title_path}"
      end
    end

    describe "GET /post/:id/delete [without auth]" do
      before(:all) do
        @del_id = Post.first.id.to_s
        get "/post/#{@del_id}/delete"
      end
      it "should reject" do
        last_response.status.should eq 401
      end
    end

    describe "GET /post/:id/delete [with auth]" do
      before(:all) do
        authorize "test", "test"
        HelpersApplication.stub(:authorized?).and_return true
        @del_id = Post.first.id.to_s
        get "/post/#{@del_id}/delete"
      end
      it "should have deleted it from data store" do
        expect { Post.load(@del_id) }.should raise_error
      end
      it "should redirect home" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == "http://example.org/"
      end
    end

  end
end
