# encoding UTF-8

module GeeklistWS
  module API
    class ResultsRepository
    	def initialize(mongo_client)
            connector = mongo_client
    		@results_collection = connector.results_collection
    	end

    	def result_in_repo?(id)
            @results_collection.find({:id => "#{id}"}).count() == 1
    	end

    	def get_result(id)
            puts id
    		result = @results_collection.find({:id => id}).first()
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