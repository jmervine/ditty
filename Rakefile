require 'rspec/core/rake_task'
require 'pp'
require 'mongo'
require 'fileutils'

begin
  require 'vlad'
  Vlad.load
rescue LoadError
  # do nothing
end

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

ENV['RACK_ENV'] ||= "stage"

namespace :unicorn do
  desc "Start unicorn"
  task :start do
    %x{ unicorn -c ./config/unicorn.rb }
  end

  desc "Start unicorn deamonized"
  task :start_d do
    %x{ unicorn -c ./config/unicorn.rb -D }
  end

  desc "Stop unicorn"
  task :stop do
    %x{ kill -QUIT $( cat log/unicorn.pid ) }
  end

  task :stop_f do
    %x{ ps aux | grep unicorn | grep -v grep | awk '{print $1}' | xargs kill -9 }
  end

  desc "Restart unicorn deamonized" 
  task :hup do
    Rake::Task['unicorn:stop'].invoke
    sleep 5
    Rake::Task['unicorn:start_d'].invoke
  end

end

namespace :import do
  task :tumblr_fetch do
    posts  = File.join( File.dirname(__FILE__), "_posts" )
    tumblr = File.join( posts, "tumblr" ) 
    tumblr_files = File.join( File.dirname(__FILE__), "tumblr_files" )
    FileUtils.rm_rf posts if File.directory? posts
    FileUtils.rm_rf tumblr if File.directory? tumblr
    FileUtils.rm_rf tumblr_files if File.directory? tumblr_files
    unless ENV['IMPORT']
      puts  "[import:tumblr] Pass blog URL via IMPORT=http://blogdomain.com"
      abort "rake aborted [import:tumblr_fetch]"
    end
    ENV['IMPORT'] = "http://" + ENV['IMPORT'] unless ENV['IMPORT'] =~ /^http\:\/\//
    require "jekyll/migrators/tumblr" 
    puts "[import:tumblr] Importing from #{ENV['IMPORT']}..."
    Jekyll::Tumblr.process(ENV['IMPORT'], true) 
    if File.directory? tumblr
      puts "[import:tumblr] Fetched:"
      puts "[import:tumblr]   From : #{ENV['IMPORT']}"
      puts "[import:tumblr]   Posts: #{`ls -l #{tumblr}/*.html | wc -l`}"
      puts "[import:tumblr]   Media: #{`ls -l #{tumblr_files}/*.* | wc -l`}"
      puts " "
    else
      abort "rake abort: files were not fetched [import:tumblr_fetch]"
    end
  end

  task :tumblr_load do
    tumblr = File.join( File.dirname(__FILE__), "_posts", "tumblr" ) 
    dbconf = YAML.load_file(File.join(File.dirname(__FILE__), "config", "ditty.yml"))[ENV['RACK_ENV']]["database"]
    connection = Mongo::Connection.new.db(dbconf['name'])[dbconf['table']]

    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "
    puts "!! WARNING                                                             !!"
    puts "!! THIS WILL BLOW AWAY YOUR CURRENT DATA, YOU HAVE 10 SECONDS TO CTL-C !!"
    puts "!! WARNING                                                             !!"
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "
    puts " "
    (1..10).each do
      print "."
      sleep 1
    end
    puts " "
    connection.remove ## WTF! WARNING!
    files = Dir[ File.join( tumblr, "*.html" ) ]
    abort "rake abort: failed to import [import:tumblr_load]" if files.empty?
    print "[import:tumblr] inserting: "
    files.each do |path|
      ta = File.basename(path).gsub(/\.html$/, "").split("-")
      post = { "created_at" => Time.new(ta[0], ta[1], ta[2]),
               "updated_at" => Time.new(ta[0], ta[1], ta[2]),
               "body"       => "" }
      file = File.open(path)
      file.each_line do |line|
        next if line =~ /^---/
        next if line =~ /^layout: post/
        post["title"] = line.gsub(/^title:/, "").strip.lstrip if line =~ /^title:/
        post["title"] = post["created_at"].strftime("Tumblr Post on %m/%d/%Y") if post["title"].empty?
        next if line =~ /^title:/
        post["body"] << line
      end
      post["body"] << "\n \n \n> _imported: [#{post["title"]}](http://f2h1gg.tumblr.com/post/#{ta[3]})_\n\n"
      post["import_id"] = ta[3].to_s 
      if connection.insert post
        print "+"
      else
        print "-"
      end
    end
    puts " "
    data_count = connection.count
    file_count = Dir[File.join(tumblr, "*.html")].count
    puts "[import:tumblr] Loaded:"
    puts "[import:tumblr]   Files:   #{file_count}"
    puts "[import:tumblr]   Records: #{data_count}"
    puts "[import:tumblr]   Missing: #{file_count-data_count}"
  end

  task :tumblr_files do
    source_dir = File.join( File.dirname(__FILE__), "tumblr_files" ) 
    public_dir = File.join( File.dirname(__FILE__), "public" ) 
    import_dir = File.join( File.dirname(__FILE__), "_posts" ) 
    abort "abort rake: #{source_dir} not found [import:tumblr_files]" unless File.directory? source_dir
    abort "abort rake: #{public_dir} not found [import:tumblr_files]" unless File.directory? public_dir
    FileUtils.cp_r source_dir, public_dir
    abort "abort rake: #{import_dir} not found [import:tumblr_files]" unless File.directory? import_dir
    FileUtils.mv source_dir, import_dir
  end
  
  desc "Import and load Tumblr blog."
  task :tumblr => ["tumblr_fetch", "tumblr_load", "tumblr_files"]
end
