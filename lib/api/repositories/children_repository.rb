# encoding UTF-8

module GeeklistWS
  module API
    class ChildrenRepository
    	def initialize
    		connector = MongoConnector.new 
    		@children_collection = connector.children_collection
            @all_collection = {}
            connector.children_collection.find().each do |child|
                child.delete("_id")
                symbolize_keys(child)
                @all_collection[child[:id]] = child
            end
            @all_collection
    	end

    	def child_in_repo?(id)
    		#@games_collection.find_one({:id => "#{id}"}, {:fields => [:id]}) != nil
            @all_collection.has_key?(id)
    	end

    	def add_child(game)  		
    		game.delete(:poster) unless game[:poster] == nil
            game.delete(:number) unless game[:number] == nil
    		@children_collection.insert(game)
            symbolize_keys(game)
            game.clone
    	end

    	def get_child(id)
    		#merged_game = @games_collection.find_one({:id => "#{game[:id]}"})
            #merged_game.delete("_id")
            #symbolize_keys(merged_game)
            @all_collection[id].clone
    	end

        def symbolize_keys(game)
            game.keys.each do |key|
                game[(key.to_sym rescue key) || key] = game.delete(key)
            end
        end

        def print_and_flush(str)
            print str
            $stdout.flush
        end
    end
  end
end