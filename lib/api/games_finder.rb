# encoding UTF-8

module GeeklistWS
  module API
    class GamesFinder
    	def initialize(geeklist)
    		@geeklist = geeklist
    	end

    	def find_games
            puts "Init"
    		@games_repository = GamesRepository.new
            @posters_repository = PostersRepository.new true
            @children_repository = ChildrenRepository.new
    		response = { :title => @geeklist[:title], :games => [], :posters => {} }
            puts "Init finished"            
    		puts "Reading #{@geeklist[:games].count}"
            @database_count = 0
            @bgg_count = 0
            posters = []
    		@geeklist[:games].each do |game|
    			print_and_flush(".")
                readed_game = get_game(game)
                readed_game[:number] = game[:number]
                readed_game[:poster] = game[:poster]
                posters << game[:poster] unless posters.include?(game[:poster])
                readed_game[:imageid] = game[:imageid]
                readed_game[:itemid] = game[:itemid]
                readed_game[:body] = game[:body]
                if !game[:children].empty?
                    readed_game[:children] = []
                    game[:children].each do |child|
                        print_and_flush(",")
                        readed_child = get_child(child[:id])
                        readed_child[:body] = child[:body]
                        readed_game[:children] << readed_child
                    end                    
                end
                response[:games] << readed_game #unless readed_game[:title] == "Unidentified Game"
    		end
            
            puts "\nFinished. Cached: #{@database_count}, Online: #{@bgg_count}"


            posters.each do |poster|
                print_and_flush(".")
                if @posters_repository.poster_in_repo?(poster)
                    readed_poster = @posters_repository.get_poster(poster)
                    if readed_poster[:collection].nil?
                        poster_collection = Readers.read_posters_collection(poster)
                        unless poster_collection.nil?
                            readed_poster[:collection] = poster_collection
                            @posters_repository.update_poster(readed_poster)
                        end
                    end
                else
                    avatar = Readers.read_poster(poster)
                    avatar = "http://mathtrade.mgpm.pl/img/meeple.png" unless avatar != "N/A"
                    poster_collection = Readers.read_posters_collection(poster)
                    @posters_repository.add_poster(poster, avatar, poster_collection)
                    readed_poster = { :name => poster, :avatar => avatar, :collection => poster_collection}
                end
                response[:posters][poster] = readed_poster
            end

            #response[:posters] = @posters_repository.get_all_posters
            puts "\nFinished. All posters: #{response[:posters].count}, list posters: #{posters.count}"

    		response
    	end

      def print_and_flush(str)
    		print str
    		$stdout.flush
  	  end

      def get_game(game)
        if @games_repository.game_in_repo?(game[:id])
            #puts "Reading from repo #{game[:id]}"
            @database_count = @database_count + 1
            readed_game = @games_repository.get_game(game[:id])
        else
            #puts "Reading from BGG #{game[:id]}"
            @bgg_count = @bgg_count + 1
            readed_game = Readers.read_game(game)
            readed_game = @games_repository.add_game(readed_game)
            readed_game.delete(:_id) if readed_game.has_key?(:_id)              
        end
        readed_game
      end

      def get_child(id)
        if @children_repository.child_in_repo?(id)
            #puts "Reading from repo #{game[:id]}"
            @database_count = @database_count + 1
            readed_game = @children_repository.get_child(id)
        else
            #puts "Reading from BGG #{game[:id]}"
            @bgg_count = @bgg_count + 1
            readed_game = Readers.read_child(id)
            readed_game = @children_repository.add_child(readed_game)
            readed_game.delete(:_id) if readed_game.has_key?(:_id)              
        end
        readed_game
      end
    end
  end
end