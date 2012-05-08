require 'spec_helper'

describe Sinatra::DirectoryHelpers do
  before(:all) do
    @helpers = TestDirectoryHelpers.new
  end
  let(:helpers) { @helpers }

  describe :store do
    it "should be set and return store path" do
      helpers.store.should eq CONFIG["store"]
    end
  end
  describe :list do
    it "should return directory contents" do
      helpers.list.should_not be_empty
      helpers.list.sort.should eq ["#{CONFIG["store"]}/2011", "#{CONFIG["store"]}/2012"].sort
    end
  end
  describe :list_all do
    it "should return all contents" do
      helpers.list_all.should_not be_empty
      helpers.list_all.count.should eq (2*6*4+(2*6)+2)
    end
  end
  describe :find_f do
    it "should return files" do
      helpers.find_f.count.should eq (2*6*4)
      helpers.find_f("file1").count.should eq (2*6*1)
    end
  end
  describe :find_d do
    it "should return directories" do
      helpers.find_d.count.should eq (2*6+2)
      helpers.find_d("11").count.should eq 2
    end
  end
  describe :mtime_sort do
    it "should sort by File.mtime" do
      s = CONFIG["store"]
      files = [
        "#{s}/2011/01/file2.txt",
        "#{s}/2012/01/file2.txt",
        "#{s}/2012/11/file1.txt"
      ]
      helpers.mtime_sort(files).should eq [
        "#{s}/2012/11/file1.txt",
        "#{s}/2012/01/file2.txt",
        "#{s}/2011/01/file2.txt"
      ]
    end
  end
  describe :latest do
    it "should return the latest _n_ files" do
      helpers.latest.count.should eq 5        
      helpers.latest(10).count.should eq 10
      helpers.latest.first.should match(/2012\/11\/file4\.txt$/)
    end
  end
  describe :delete do
    it "should remove a file" do
      file = helpers.mtime_sort(helpers.find_f).last
      helpers.delete(file).should be
      File.exists?(file).should_not be_true
    end
  end
  describe :create do
    it "should raise an error if it can't create the file" do
      expect { helpers.create("/should_fail.txt", "foo") }.should raise_error
    end
    it "should raise an error if the file exists" do
      expect { helpers.create(File.join(CONFIG["store"], "2012", "01", "file1.txt"), "foo") }.should raise_error StandardError
    end
    it "should create a file with passed data" do
      file = File.join(CONFIG["store"], "2012", "12", "file1.txt")
      helpers.create(file, "foobar").should be
      File.exists?(file).should be_true
      File.read(file).should match /foobar/
    end
  end
  describe :update do
    it "should raise an error if it can't find the file" do
      expect { helpers.create("/should_fail.txt", "foo") }.should raise_error
    end
    it "should update the file" do
      file = File.join(CONFIG["store"], "2012", "12", "file1.txt")
      File.read(file).should match /foobar/
      helpers.update(file, "bazboo").should be_true
      File.read(file).should_not match /foobar/
      File.read(file).should match /bazboo/
    end
  end
end
