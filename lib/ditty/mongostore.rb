require 'mongo'
module Ditty
  class MongoStore
    attr_reader :name, :database, :table, :connection, :collection
    def initialize( opts )
      @name       = opts["name"]
      @table      = opts["table"]
      @username   = opts["username"]||nil #(opts.has_key?("auth") ? opts["auth"]["username"] : nil)
      @password   = opts["password"]||nil #(opts.has_key?("auth") ? opts["auth"]["password"] : nil)
      @connection = Mongo::Connection.new
      begin
        if auth?
          @connection.add_auth(@name, @username, @password) 
          @auth_worked = true
        end
      rescue
        @auth_worked = false  
      end
      @database   = @connection.db(@name)
      @collection = @database[@table]
    end
    def find opts=nil
      return collection.find.to_a if opts.nil?
      if opts.has_key? "_id" and not opts["_id"].kind_of? BSON::ObjectId
        opts["_id"] = BSON::ObjectId(opts["_id"])
      end
      return collection.find(opts).to_a
    end
    def auth?
      return @auth_worked if defined?(@auth_worked)
      return !(@username.nil? || @password.nil?)
    end
    def method_missing(meth, *args, &block)
      begin
        collection.send(meth, *args, &block)
      rescue
        super
      end
    end
  end
end

