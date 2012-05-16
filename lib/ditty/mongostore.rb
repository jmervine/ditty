require 'mongo'
module Ditty
  class MongoStore
    attr_reader :database, :table, :connection
    def initialize( database, table, opts = {} )
      # Mongo::Connection.new.db("irbdb")['test']
      @database   = database
      @table      = table
      @connection = Mongo::Connection.new.db(database)[table]
    end
    def find opts=nil
      return connection.find.to_a if opts.nil?
      if opts.has_key? "_id" and not opts["_id"].kind_of? BSON::ObjectId
        opts["_id"] = BSON::ObjectId(opts["_id"])
      end
      return connection.find(opts).to_a
    end
    def method_missing(meth, *args, &block)
      begin
        connection.send(meth, *args, &block)
      rescue
        super
      end
    end
  end
end

