# encoding UTF-8

module GeeklistWS
  module API
    class ChildrenRepository
    	def initialize
    		connector = MongoConnector.new 
    		@children_collection = connector.children_collection
    	end

    	def child_in_repo?(id)
            @children_collection.find({:id => "#{id}"}).count() == 1
    	end

    	def add_child(game)  		
    		game.delete(:poster) unless game[:poster] == nil
            game.delete(:number) unless game[:number] == nil
            game[:created] = DateTime.now.to_time.utc
    		@children_collection.insert(game)
            symbolize_keys(game)
            game.clone
    	end

    	def get_child(id)
            child = @children_collection.find({:id => "#{id}"}).first()
            child.delete("_id")
            symbolize_keys(child)
            child
    	end

        def get_childs(keys)
            result = {}
            @children_collection.find({:id => { "$in" => keys } }).each do |game|
                game.delete("_id")
                symbolize_keys(game)
                result[game[:id]] = game
            end
            result
        end

        def symbolize_keys(child)
            child.keys.each do |key|
                child[(key.to_sym rescue key) || key] = child.delete(key)
            end
        end
    end
  end
end