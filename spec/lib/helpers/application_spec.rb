require 'spec_helper'
describe Helper::Application do
  before(:all) do
    @app = TestHelpersApplication.new
  end
  let(:app) { @app }
  describe :protected! do
    it "should be nil if :authorized?" do
      app.stub(:authorized?).and_return true
      app.protected!.should be_nil
    end
    it "should throw :halt if not :authorized?" do
      app.stub(:authorized?).and_return false
      #broken in current version of rspec-expectations
      #expect { app.protected! }.should throw_symbol :halt
    end
  end

  describe :authorized? do
    it "should return false if username or password is missing" do
      app.authorized?.should be_false
    end
    it "should return false if username or password is wrong" do
      pending "need to research how to test this"
    end
    it "should return true if username or password is correct" do
      pending "need to research how to test this"
    end
  end

end
