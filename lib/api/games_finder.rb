# encoding UTF-8

module GeeklistWS
  module API
    class GamesFinder
    	def initialize(geeklist)
    		@geeklist = geeklist
    	end

    	def find_games
    		@games_repository = GamesRepository.new
            @posters_repository = PostersRepository.new
    		response = { :title => @geeklist[:title], :games => [], :posters => {} }
    		puts "Reading #{@geeklist[:games].count}"
            database_count = 0
            bgg_count = 0
            posters = []
    		@geeklist[:games].each do |game|
    			print_and_flush(".")
    			if @games_repository.game_in_repo?(game[:id])
    				#puts "Reading from repo #{game[:id]}"
                    database_count = database_count + 1
                    readed_game = @games_repository.get_game(game[:id])
    			else
    				#puts "Reading from BGG #{game[:id]}"
                    bgg_count = bgg_count + 1
    				readed_game = Readers.read_game(game)
    				readed_game = @games_repository.add_game(readed_game)
    				readed_game.delete(:_id) if readed_game.has_key?(:_id) 				
    			end
                readed_game[:number] = game[:number]
                readed_game[:poster] = game[:poster]
                posters << game[:poster] unless posters.include?(game[:poster])
                readed_game[:imageid] = game[:imageid]
                readed_game[:itemid] = game[:itemid]
                readed_game[:body] = game[:body]
                response[:games] << readed_game #unless readed_game[:title] == "Unidentified Game"
    		end
            
            puts "\nFinished. Cached: #{database_count}, Online: #{bgg_count}"

            posters.each do |poster|
                print_and_flush(".")
                if @posters_repository.poster_in_repo?(poster)
                    readed_poster = @posters_repository.get_poster(poster)
                    avatar = readed_poster[:avatar]
                else
                    avatar = Readers.read_poster(poster)
                    @posters_repository.add_poster(poster, avatar)
                end
                response[:posters][poster] = avatar unless avatar == "N/A"
            end

            puts "\nFinished. Posters: #{posters.count}"

    		response
    	end

      def print_and_flush(str)
    		print str
    		$stdout.flush
  	  end
    end
  end
end