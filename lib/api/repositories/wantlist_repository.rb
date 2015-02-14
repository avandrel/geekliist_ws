# encoding UTF-8

module GeeklistWS
  module API
    class WantlistRepository
    	def initialize
    		connector = MongoConnector.new 
    		@wantlist_collection = connector.wantlist_collection
    	end

    	def wantlist_in_repo?(id)
            @wantlist_collection.find_one({:id => id.to_i}) != nil
    	end

    	def get_wantlist(id)
    		result = @wantlist_collection.find_one({:id => id.to_i})
            result.delete("_id")
            symbolize_keys(result)
            result
    	end

        def symbolize_keys(result)
            result.keys.each do |key|
                result[(key.to_sym rescue key) || key] = result.delete(key)
            end
            result.values.each do |value|
                if value.is_a?(Array)
                    value.each do |hash| 
                        hash.keys.each do |key|
                            hash[(key.to_sym rescue key) || key] = hash.delete(key)
                        end
                    end
                end
            end
        end
    end
  end
end