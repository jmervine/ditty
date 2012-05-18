module Ditty
  class Item < Hash

    # Item and it's sub-classes can be used with
    # and data store (json, yaml, mysql, etc.). 
    # However, you need to implement a handler 
    # which supports the following four calls:
    #
    # * find   - returns an array items
    # * insert - saves a new item
    # * update - updates an existing item
    # * remove - removes passed or all records
    #

    @@data_store = nil # default data_store could be set here
    def self.data_store=(s)
      @@data_store = s
    end

    def data_store=(s)
      @@data_store = s
    end

    def data_store
      @@data_store
    end

    def self.data_store
      @@data_store
    end

    def initialize options={}
      options.each { |opt, val| store opt.to_s, val }
      return self
    end

    def self.load item
      if item.kind_of? Hash
        return self.new.merge item
      else
        raise MissingDataStoreError if @@data_store.nil?
        return self.new.merge(data_store.find("_id" => item).first)
      end
    end

    # overwrite hash methods to be strict
    def keys_public
      [ "title", "body" ]
    end

    def keys_protected
      [ "created_at", "updated_at", "_id" ]
    end

    def keys_all
      keys_public+keys_protected
    end

    def store k,v
      k = (k.kind_of? Symbol) ? k.to_s : k
      raise InvalidOptionError, "#{k} cannot be set" unless keys_public.include? k 
      super k,v 
    end

    def []= k,v
      store k,v
    end

    def [] k
      return fetch if k == "_id"
      super
    end

    def id
      fetch "_id" rescue nil
    end

    def update
      raise InvalidSaveError, "on update item does not exist" unless keys.include? "_id" 
      data_store.update( { "_id" => fetch("_id") }, self.merge!("updated_at" => Time.now) )
    end

    def insert 
      raise InvalidSaveError, "on create item already exists" if keys.include? "_id" 
      time = Time.now
      self.merge!("_id" => data_store.insert(self.merge!("created_at" => time, "updated_at" => time)))
    end

    def save
      update if keys.include? "_id" # else
      insert 
    end

    def remove 
      raise InvalidSaveError, "on delete item does not exist " unless keys.include? "_id" 
      id = fetch("_id")
      if data_store.remove("_id" => id)
        keys_protected.each { |k| self.delete(k) }
      end
    end

    # meta messy
    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^(.+)=$/
        return store($1, args.first) if keys_public.include?($1)
      end
      if keys_all.include? meth.to_s
        return fetch(meth.to_s) rescue return nil #raise InvalidOptionError, "#{meth} not set"
      end
      #return fetch(meth.to_s) if keys_all.include? meth.to_s rescue nil
      super
    end
  end

  class MissingDataStoreError < Exception; end
  class InvalidOptionError < Exception; end
  class InvalidSaveError < Exception; end
end
