require 'pstore' #file store

require 'securerandom' # file store  uuid
require 'ostruct'

module FileStore
  class Object
    attr_accessor :bucket
    attr_reader :key
    attr_accessor :raw_data, :content_type, :object_path
    def initialize(key,bucket)
      @bucket = bucket
      @key = key

      @object_path = ["object",bucket.keyify(self.key)].join("~")
 
    end
    def indexes=(*args)
      # not implemented
    end
    def store

        bucket.store.transaction do
          bucket.store[bucket.keyify(self.key)] = self.object_path
          bucket.store[bucket.keyify('index')] ||= Array.new
          bucket.store[bucket.keyify('index')] << bucket.keyify(self.key)
        end
        
        File.open(self.object_path, "w+b") do |f|
          f << raw_data
        end
        puts "commited #{bucket.keyify(self.key)}"
    end
    class << self 
      def load(key,bucket)
        o = Object.new(key,bucket)
        o.raw_data = IO.read(o.object_path)
        o
      end
    end
  end 

  class Bucket
    attr_accessor :name, :store, :key
    def initialize(name,store)
      @name = name
      @store = store
    end
    def get_or_new(key)
      Object.new(key,self)
    end

    def [](keyified) # get
      obj = nil
      self.store.transaction(true) do
        obj = self.store[keyified]
      end
      if obj == nil
        raise "#{keyified} Object has no value "
      end
      Object.load(self.unkeyify(keyified),self)
    end

    def unkeyify(keyif)
      keyif.split(":").last
    end

    def keyify(*args)
      ([self.name] | args).join(':')
    end

    def delete(key)
      self.store.transaction do
        self.store.delete(key)
      end
    end
  end
  class Stamp
    def next
      SecureRandom.uuid
    end
  end

  class IndexSet
    attr_accessor :bucket
    def initialize(bucket)
      self.bucket = bucket 
    end
    def each(&block)
      index = []
      bucket.store.transaction(true) do
        index = bucket.store[bucket.keyify('index')]
      end
      index.each do | key |
        block.call( key )
      end
    end
  end


  class Client
    attr_reader :store
    def initialize(*args)
      storage_path = "./filestore.pstore"
      @store = PStore.new(storage_path)
    end
    def bucket(name)
      Bucket.new(name,@store)
    end
    alias  :[] :bucket

    def stamp
      Stamp.new
    end
    def get_index(name,*rest)
      IndexSet.new(self.bucket(name))
    end
  end
end

