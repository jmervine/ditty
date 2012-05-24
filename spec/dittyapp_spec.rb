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
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should have post titles" do
      last_response.should match Regexp.new("post title - ")
    end
    it "should have post bodies" do
      last_response.should match Regexp.new("post body - ")
    end
    it "post titles should be a link" do
      last_response.should match Regexp.new("<a href=\'\/post\/([a-z0-9]+)'>post title - (.+)</a>")
    end
    it "should have login link when not authorized" do
      HelpersApplication.stub(:authorized?).and_return false
      last_response.should match Regexp.new(Regexp.escape("login</a>"))
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      HelpersApplication.stub(:authorized?).and_return true
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "GET /post", "without auth" do
    before(:all) do
      get "/post"
    end
    it "should reject" do
      last_response.status.should be 401
    end
  end

  describe "GET /post", "with auth" do 
    before(:all) do
      authorize 'test', 'test'
      HelpersApplication.stub(:authorized?).and_return true
      get "/post"
    end
    it "should load new post form" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should not have a trailing slash at the end of the form action" do
      last_response.should match /action=\"\/post\"/
    end
    it "should have a submit button" do
      last_response.should match Regexp.new(Regexp.escape('<input class="button" type="submit" value="Save!" />'))
    end
    it "should have help nav" do
      last_response.should match Regexp.new(Regexp.escape('Markdown Help'))
    end
  end

  describe "GET /post/:id" do
    before(:all) do
      get "/post/#{Ditty::Post.first.id.to_s}" # find a real post via it's id
    end
    it "should load post" do
      last_response.should be_ok
    end
    it "should not have default title" do
      last_response.should_not match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should have post title" do
      last_response.should match Regexp.new("post title - ")
    end
    it "should have post body" do
      last_response.should match Regexp.new("<p>post body - ")
    end
    it "post title should be a link" do
      last_response.should match Regexp.new("<a href=\'\/post\/([a-z0-9]+)'>post title - (.+)</a>")
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new(Regexp.escape(Ditty::Post.first.title))
      last_response.should match Regexp.new(Regexp.escape(Ditty::Post.first.body))
    end
  end

  describe "GET /post/:id/edit", "without auth" do
    before(:all) do
      get "/post/#{Ditty::Post.first.id.to_s}/edit" # find a real post via it's id
    end
    it "should reject" do
      last_response.status.should be 401
    end
  end

  describe "GET /post/:id/edit", "with auth" do
    before(:all) do
      authorize 'test', 'test'
      HelpersApplication.stub(:authorized?).and_return true
      get "/post/#{Ditty::Post.first.id.to_s}/edit" # find a real post via it's id
    end
    it "should load post edit form" do
      last_response.should be_ok
    end
    it "should not have default title" do
      last_response.should_not match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should have post title" do
      last_response.should match Regexp.new("post title - ")
    end
    it "should have post body" do
      last_response.should match Regexp.new("post body - ")
    end
    it "post body should be raw markdown" do
      last_response.should_not match Regexp.new("<p>post body - ")
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new(Regexp.escape(Ditty::Post.first.title))
      last_response.should match Regexp.new(Regexp.escape(Ditty::Post.first.body))
    end
    it "should have a submit button" do
      last_response.should match Regexp.new(Regexp.escape('<input class="button" type="submit" value="Save!" />'))
    end
    it "should have help nav" do
      last_response.should match Regexp.new(Regexp.escape('Markdown Help'))
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
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "post title should be a link" do
      last_response.should match Regexp.new("<a href=\'\/post\/([a-z0-9]+)'>post title - (.+)</a>")
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
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
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should have not new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "post title should be a link" do
      last_response.should match Regexp.new("<a href=\'\/post\/([a-z0-9]+)'>post title - (.+)</a>")
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
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
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "post title should be a link" do
      last_response.should match Regexp.new("<a href=\'\/post\/([a-z0-9]+)'>post title - (.+)</a>")
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
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
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
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
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
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
      put "/bad/path"
    end
    it "should return a 404" do
      last_response.status.should eq 404
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "POST /post", "without auth" do
    before(:all) do
      post "/post", :post => { "title" => "create test title", "body" => "create test body" }
    end
    it "should reject" do
      last_response.status.should be 401
    end
  end

  describe "POST /post" do
    before(:all) do
      authorize "test", "test"
      HelpersApplication.stub(:authorized?).and_return true
      post "/post", :post => { "title" => "create test title", "body" => "create test body" }
    end
    it "should have added to the data store" do
      Ditty::Post.where(:title => "create test title").should be
    end
    it "should load created post" do
      last_response.should be_ok
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should have edit post link" do
      last_response.should match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should not have default title" do
      last_response.should_not match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new("create test title")
      last_response.should match Regexp.new("create test body")
    end
  end

  describe "POST /post/:id", "without auth" do
    before(:all) do
      post "/post/#{Ditty::Post.last.id.to_s}", :post => { "title" => "updated test title", "body" => "updated test body" }
    end
    it "should reject" do
      last_response.status.should be 401
    end
  end

  describe "POST /post/:id" do
    before(:all) do
      authorize "test", "test"
      HelpersApplication.stub(:authorized?).and_return true
      @update_id = Ditty::Post.last.id.to_s
      post "/post/#{@update_id}", :post => { "title" => "updated test title", "body" => "updated test body" }
    end
    it "should have added to the data store" do
      Ditty::Post.find(@update_id).should be
    end
    it "should have changed updated_at" do
      Ditty::Post.find(@update_id).title.should eq "updated test title"
    end
    it "should load the updated post" do
      last_response.should be_ok
    end
    it "should not have default title" do
      last_response.should_not match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should not have new post link" do
      last_response.should_not match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should have edit post link" do
      last_response.should match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should be the right post" do
      last_response.should match Regexp.new("updated test title")
      last_response.should match Regexp.new("updated test body")
    end
  end

  describe "DELETE /post/:id", "without auth" do
    before(:all) do
      @del_id = Ditty::Post.first.id.to_s
      get "/post/#{@del_id}/delete"
    end
    it "should reject" do
      last_response.status.should be 401
    end
  end

  describe "DELETE /post/:id" do
    before(:all) do
      authorize "test", "test"
      HelpersApplication.stub(:authorized?).and_return true
      @del_id = Ditty::Post.first.id.to_s
      get "/post/#{@del_id}/delete"
    end
    it "should have deleted it from data store" do
      expect { Ditty::Post.load(@del_id) }.should raise_error
    end
    it "should load the index" do
      last_response.should be_ok
    end
    it "should have title" do
      last_response.should match Regexp.new(Regexp.escape("<title>My TEST Ditty's!</title>"))
    end
    it "should have new post link" do
      last_response.should match Regexp.new(Regexp.escape("new post</a>"))
    end
    it "should not have edit post link" do
      last_response.should_not match Regexp.new(Regexp.escape("edit post</a>"))
    end
    it "should have archive" do
      last_response.should match Regexp.new(Regexp.escape('Archive</a>'))
    end
    it "should have archive list items" do
      last_response.should match Regexp.new(Regexp.escape("<a href='/archive"))
    end
    it "should have posts" do
      last_response.should match Regexp.new(Regexp.escape("post body"))
      last_response.should match Regexp.new(Regexp.escape("post title"))
    end
  end

  describe "GET /login", "without auth" do
    before(:all) do
      get "/login"
    end
    it "should reject" do
      last_response.status.should be 401
    end
  end

  describe "GET /login", "with auth, without :from" do 
    before(:all) do
      authorize 'test', 'test'
      HelpersApplication.stub(:authorized?).and_return true
      get "/login"
    end
    it "should load new post form" do
      last_response.should be_ok
    end
  end

end
