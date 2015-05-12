# encoding UTF-8

module GeeklistWS
  module API
    class GamesFinder
      def initialize(geeklist, url)
        @geeklist = geeklist
        start_time = Time.now
        @games_repository = GamesRepository.new
        @posters_repository = PostersRepository.new
        @children_repository = ChildrenRepository.new
        puts "Initialized, Elapsed: #{Time.now - start_time}[s]"
        @bgg_count = 0
        @database_count = 0
        @url = url
      end

      def find_games
        puts "Init"
        response = { :title => @geeklist[:title], :games => [], :posters => {} }
        puts "Init finished"
        puts "Reading #{@geeklist[:games].count}"
        @database_count = 0
        @bgg_count = 0
        posters = []
        i = 0
        start_time = Time.now
        games_from_repo = get_games_from_repo(@geeklist[:games].keys)
        childs_from_repo = get_childs_from_repo(@geeklist[:games].values)
        posters_from_repo = get_posters_from_repo(@geeklist[:games].values)
        while !validate(@geeklist[:games].count, games_from_repo.count)
            refresh_games
            games_from_repo = get_games_from_repo(@geeklist[:games].keys)
            childs_from_repo = get_childs_from_repo(@geeklist[:games].values)
            posters_from_repo = get_posters_from_repo(@geeklist[:games].values)
        end
        repo_time = Time.now
        @geeklist[:games].each do |itemid, game|
          print_and_flush("|") if i % 100 == 0
          readed_game = games_from_repo[itemid]
          readed_game[:number] = game[:number]
          readed_game[:poster] = game[:poster]
          readed_game[:imageid] = game[:imageid]
          readed_game[:itemid] = game[:itemid]
          readed_game[:body] = game[:body]
          if !game[:children].empty?
            readed_game[:children] = []
            game[:children].each do |child|
              readed_child = childs_from_repo[child[:id]]
              readed_child[:body] = child[:body]
              readed_game[:children] << readed_child
            end

          end
          response[:games] << readed_game #unless readed_game[:title] == "Unidentified Game"
          i = i + 1
        end

        posters_from_repo.each do |name, poster|
          response[:posters][name] = { :name => name, :avatar => poster[:avatar]}
        end

        finished_time = Time.now
        puts "\nFinished. Repo time: #{repo_time - start_time}[s], Whole: #{finished_time - start_time}"

        response
      end

      def find_some_games(games)
        refresh_games
        games_dictionary = {}
        games.each do |game|
            games_dictionary[game] = @geeklist[:games].values.find{ |list_game| list_game[:number] == game.to_i }[:itemid]
        end
        games_from_repo = get_games_from_repo(games_dictionary.values)
        readed_games = {}
        games_dictionary.each do |number, itemid|
          readed_games[number] = { :id => games_from_repo[itemid][:id], :title => games_from_repo[itemid][:title], :imageid => games_from_repo[itemid][:imageid], :itemid => games_from_repo[itemid][:itemid]}
        end
        readed_games
      end

      def refresh_games
        puts "Begin refresh_games"
        start_time = Time.now
        games_from_repo = get_games_from_repo(@geeklist[:games].keys)
        repo_time = Time.now
        result = ""
        games_to_refresh = @geeklist[:games].keys - games_from_repo.keys
        counter = 0
        start_time = Time.now
        games_to_refresh.each do |itemid|
          refresh_game(@geeklist[:games][itemid])
          counter = counter + 1
          time = Time.now - start_time
          break if time > 25
        end

        result = result + "\nGames refresh -> Name: #{@geeklist[:title]}, Elapsed: #{Time.now - start_time}[s], Counter: #{counter}/#{games_to_refresh.count}" if counter > 0
        childs_from_repo = get_childs_from_repo(@geeklist[:games].values)
        childs_to_refresh = get_child_ids(@geeklist[:games].values) - childs_from_repo.keys
        childs_to_refresh.each do |id|
          refresh_child(id)
          counter = counter + 1
          time = Time.now - start_time
          break if time > 25
        end

        result = result +  "\nChildren refresh -> Name: #{@geeklist[:title]}, Elapsed: #{Time.now - start_time}[s], Counter: #{counter}/#{childs_to_refresh.count}" if counter > 0        

        posters_from_repo = get_posters_from_repo(@geeklist[:games].values)
        posters_to_refresh = @geeklist[:games].values.uniq{|game| game[:poster]}.map{|game| game[:poster]} - posters_from_repo.keys
        posters_to_refresh.each do |name|
          refresh_poster(name)
          counter = counter + 1
          time = Time.now - start_time
          break if time > 25
        end

        result +  "\nPosters refresh -> Name: #{@geeklist[:title]}, Elapsed: #{Time.now - start_time}[s], Counter: #{counter}/#{posters_to_refresh.count}" if counter > 0      
      end

      def refresh_game(game)
        unless @games_repository.game_in_repo?(game[:itemid])
          start_time = Time.now
          readed_game = get_game(game)
          if !game[:children].empty?
            game[:children].each do |child|
              get_child(child[:id]) unless @children_repository.child_in_repo?(child[:id])
            end
          end

          unless @posters_repository.poster_in_repo?(game[:poster])
            avatar = Readers.read_poster(game[:poster])
            avatar = "http://mathtrade.mgpm.pl/img/meeple.png" unless avatar != "N/A"
            @posters_repository.add_poster(game[:poster], avatar)
          end
          puts "#{game[:itemid]} refreshing finished after #{Time.now - start_time}"
        end
      end

      def refresh_poster(name)
        avatar = Readers.read_poster(name)
        avatar = "http://mathtrade.mgpm.pl/img/meeple.png" unless avatar != "N/A"
        @posters_repository.add_poster(name, avatar)
      end

      def print_and_flush(str)
        print str
        $stdout.flush
      end

      def get_game(game)
        puts "Reading from BGG #{game[:id]}"
        @bgg_count = @bgg_count + 1
        readed_game = Readers.read_game(game)
        return readed_game if readed_game.is_a?(OpenURI::HTTPError)
        readed_game = @games_repository.add_game(readed_game, @geeklist[:id])
        readed_game.delete(:_id) if !readed_game.nil? && readed_game.has_key?(:_id)
      end

      def get_games_from_repo(keys)
        @games_repository.get_games(keys)
      end

      def validate(expected, actual)
        expected == actual
      end

      def get_childs_from_repo(games)
        child_ids = get_child_ids(games)
        @children_repository.get_childs(child_ids)
      end

      def get_child_ids(games)
        child_ids = []
        games.select{|game| !game[:children].empty?}.each do |game|
          game[:children].each do |child|
            child_ids << child[:id] unless child_ids.include?(child[:id])
          end
        end
        child_ids
      end

      def get_posters_from_repo(games)
        @posters_repository.get_posters(games.uniq{|game| game[:poster]}.map{|game| game[:poster]})
      end

      def refresh_child(id)
        @children_repository.add_child(Readers.read_child(id))
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
          return readed_game if readed_game.is_a?(OpenURI::HTTPError)
          readed_game = @children_repository.add_child(readed_game)
          readed_game.delete(:_id) if readed_game.has_key?(:_id)
        end
        readed_game
      end
    end
  end
end
