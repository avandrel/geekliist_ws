# encoding UTF-8

module GeeklistWS
  module API
    class ResultsRepository
    	def initialize
    		connector = MongoConnector.new 
    		@results_collection = connector.results_collection
    	end

    	def result_in_repo?(id)
            @results_collection.find_one({:id => "#{id}"}) != nil
    	end

    	def get_result(id)
            puts id
    		result = @results_collection.find_one({:id => id})
            result.delete("_id")
            symbolize_keys(result)
            result
    	end

        def symbolize_keys(result)
            result.keys.each do |key|
                result[(key.to_sym rescue key) || key] = result.delete(key)
            end
        end
    end
  end
end