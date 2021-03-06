# encoding UTF-8

require 'zlib'
require 'base64'

module GeeklistWS
  module API
    class ListRepository
    	def initialize(mongo_client)
    		connector = mongo_client
    		@list_collection = connector.list_collection
    	end

        def list_in_repo?(id)
            @list_collection.find({:id => "#{id}"}).first() != nil
        end

        def add_list(id, list, use_cache)          
            encoded = Base64.encode64 Zlib::Deflate.deflate(list)
            insert = { :id => "#{id}", :list => "#{encoded}" }
            if use_cache == 1
                insert[:created] = DateTime.now.to_time.utc
            end
            @list_collection.insert_one(insert)
        end

        def get_list(id)
            list = @list_collection.find({:id => "#{id}"}).first()
            list.delete("_id")
            symbolize_keys(list)
            Zlib::Inflate.inflate(Base64.decode64(list[:list]))
        end

        def symbolize_keys(list)
            list.keys.each do |key|
                list[(key.to_sym rescue key) || key] = list.delete(key)
            end
        end
    end
  end
end