# encoding UTF-8

module GeeklistWS
  module API
    class PostersRepository
    	def initialize(mongo_client)
            connector = mongo_client
            @posters_collection = connector.posters_collection    
    	end

    	def poster_in_repo?(name)
    		@posters_collection.find({:name => "#{name}"}).count() == 1
    	end

    	def add_poster(poster, avatar)
            payload = { :name => poster, :avatar => avatar }
            #payload[:collection] = posters_collection unless posters_collection.nil?
            #payload[:created] = DateTime.now.to_time.utc
            puts payload.inspect
    		@posters_collection.insert_one(payload) unless payload[:name].nil?
    	end

    	def get_poster(name)
            poster = @posters_collection.find({:name => "#{name}"}).first()
            poster.delete("_id")
            symbolize_keys(poster)
            poster
    	end

        def get_posters(names)
            result = {}
            @posters_collection.find({:name => { "$in" => names } }).each do |poster|
                poster.delete("_id")
                symbolize_keys(poster)
                result[poster[:name]] = poster
            end
            result
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
            @posters_collection.insert_one(payload)
        end
    end
  end
end