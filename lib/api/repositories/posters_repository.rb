# encoding UTF-8

module GeeklistWS
  module API
    class PostersRepository
    	def initialize(all)
    		connector = MongoConnector.new 
            if all
                @posters_collection = connector.posters_collection
                @all_collection = {}
                connector.posters_collection.find().each do |poster|
                    poster.delete("_id")
                    symbolize_keys(poster)
                    @all_collection[poster[:name]] = poster
                end
                @all_collection
            else
                @posters_collection = connector.bggusers_collection
            end
    	end

    	def poster_in_repo?(name)
    		#@games_collection.find_one({:id => "#{id}"}, {:fields => [:id]}) != nil
            @all_collection.has_key?(name)
    	end

    	def add_poster(poster, avatar)
            payload = { :name => poster, :avatar => avatar }
            #payload[:collection] = posters_collection unless posters_collection.nil?
            payload[:created] = DateTime.now.to_time.utc
    		@posters_collection.insert(payload)
    	end

    	def get_poster(name)
    		#merged_game = @games_collection.find_one({:id => "#{game[:id]}"})
            #merged_game.delete("_id")
            #symbolize_keys(merged_game)
            @all_collection[name].clone
    	end

        def symbolize_keys(poster)
            poster.keys.each do |key|
                poster[(key.to_sym rescue key) || key] = poster.delete(key)
            end
        end

        def one_user_in_repo(poster)
            result = @posters_collection.find_one({:name => "#{poster}"}, {:fields => [:name]})
            result.nil? ? nil : result
        end

        def add_user(poster, posters_collection)
            payload = { :name => poster, :collection => posters_collection }
            payload[:created] = DateTime.now.to_time.utc
            @posters_collection.insert(payload)
        end
    end
  end
end