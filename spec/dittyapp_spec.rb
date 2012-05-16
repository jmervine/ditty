require 'spec_helper'

describe DittyApp, "< Sinatra::Application" do
  before(:all) do
    build_clean_data
  end

  describe "GET /" do
    before(:all) do
      get "/"
    end
    it "should load index page" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "GET /post" do 
    before(:all) do
      get "/post"
    end
    it "should load new post form" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have a submit button" do
      last_response.should match Regexp.new(Regexp.escape('<input class="button" type="submit" value="Save!" />'))
    end
    it "should have help nav" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Markdown Help</h3>'))
    end
  end

  describe "GET /post/:id" do
    before(:all) do
      get "/post/#{settings.store.find.first["_id"]}" # find a real post via it's id
    end
    it "should load post" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new(Regexp.escape(settings.store.find.first["title"]))
      last_response.should match Regexp.new(Regexp.escape(settings.store.find.first["body"]))
    end
  end

  describe "GET /post/:title" do
    before(:all) do
      get "/post/post%20title%20-%202011.7.9" 
    end
    it "should load a post" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new(Regexp.escape("post title - 2011.7.9"))
      last_response.should match Regexp.new(Regexp.escape("post body - 2011.7.9"))
      last_response.should match Regexp.new(Regexp.escape("Created on July 09, 2011"))
    end
  end

  describe "GET /edit/:id" do
    before(:all) do
      get "/edit/#{settings.store.find.first["_id"]}" # find a real post via it's id
    end
    it "should load post edit form" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new(Regexp.escape(settings.store.find.first["title"]))
      last_response.should match Regexp.new(Regexp.escape(settings.store.find.first["body"]))
    end
    it "should have a submit button" do
      last_response.should match Regexp.new(Regexp.escape('<input class="button" type="submit" value="Save!" />'))
    end
    it "should have help nav" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Markdown Help</h3>'))
    end
  end

  describe "GET /edit/:title" do
    before(:all) do
      get "/edit/post%20title%20-%202011.7.9" 
    end
    it "should load post edit form" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new(Regexp.escape("post title - 2011.7.9"))
      last_response.should match Regexp.new(Regexp.escape("post body - 2011.7.9"))
    end
    it "should have a submit button" do
      last_response.should match Regexp.new(Regexp.escape('<input class="button" type="submit" value="Save!" />'))
    end
    it "should have help nav" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Markdown Help</h3>'))
    end
  end

  describe "GET /archive" do
    before(:all) do
      get "/archive"
    end
    it "should load" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
  end

  describe "GET /archive/:year" do
    before(:all) do
      get "/archive/2012"
    end
    it "should load" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
  end

  describe "GET /archive/:year/:month" do
    before(:all) do
      get "/archive/2012/05"
    end
    it "should load" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "GET /bad/path" do
    before(:all) do
      get "/bad/path"
    end
    it "should return a 404" do
      last_response.status.should eq 404
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "POST /bad/path" do
    before(:all) do
      post "/bad/path"
    end
    it "should return a 404" do
      last_response.status.should eq 404
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "BAD /bad/path" do
    before(:all) do
      delete "/bad/path"
    end
    it "should return a 404" do
      last_response.status.should eq 404
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "POST /post" do
    before(:all) do
      post "/post", :params => { :title => "create test title", :body => "create test body" }
    end
    it "should have added to the data store" do
      this = Post.load(settings.store.find.last)
      this.title.should eq "create test title"
    end
    it "should load created post" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new("create test title")
      last_response.should match Regexp.new("create test body")
    end
  end

  describe "POST /post/:id" do
    before(:all) do
      @update_id = settings.store.find.last['_id'].to_s
      post "/post/#{@update_id}", :params => { :title => "updated test title", :body => "updated test body" }
    end
    it "should have added to the data store" do
      this = Post.load(@update_id)
      this.title.should eq "updated test title"
    end
    it "should have changed updated_at" do
      this = Post.load(@update_id)
      this.updated_at.should_not eq this.created_at
    end
    it "should load the updated post" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new("updated test title")
      last_response.should match Regexp.new("updated test body")
    end
  end

  describe "DELETE /post/:id" do
    before(:all) do
      @del_id = settings.store.find.last['_id'].to_s
      delete "/post/#{@del_id}"
    end
    it "should have deleted it from data store" do
      expect { Post.load(@update_id) }.should raise_error
    end
    it "should load the index" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My little Ditty's!</title>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('<h3 class="sub_header">Archive</h3>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

end