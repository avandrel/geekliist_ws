require 'zlib'
require 'base64'

module GeeklistWS
  module API
    class ListRepository
    	def initialize
    		connector = MongoConnector.new 
    		@list_collection = connector.list_collection
    	end

        def list_in_repo?(id)
            @list_collection.find_one({:id => "#{id}"}) != nil
        end

        def add_list(id, list)          
            encoded = Base64.encode64 Zlib::Deflate.deflate(list)
            @list_collection.insert({ :id => "#{id}", :list => "#{encoded}", :created => DateTime.now.to_time.utc })
        end

        def get_list(id)
            list = @list_collection.find_one({:id => "#{id}"})
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