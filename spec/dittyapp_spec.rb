require 'spec_helper'

describe DittyApp, "< Sinatra::Application" do
  before(:all) do
    build_clean_data
  end

  describe "GET /" do
    before(:all) do
      get "/"
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

  describe "GET /new" do 
    before(:all) do
      get "/new"
    end
    it "should load" do
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
    it "should load" do
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
    it "should load" do
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
    it "should load" do
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
    it "should load" do
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

  #describe "GET /bad/path" do
    #it "should load an error page" do
      #pending
    #end
  #end

  #describe "GET /archive/(?*)" do
    #it "should load a list of all posts" do
      #pending
    #end
    #it "should load a list of specific posts if qualified" do
      #pending
    #end
  #end

  pending "tests need a lot of love"

end
