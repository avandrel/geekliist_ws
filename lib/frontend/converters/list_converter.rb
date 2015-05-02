# encoding UTF-8

module GeeklistWS
  module Frontend
    class ListConverter
    	def initialize(response, category, user, url)
    		@games = response[:games]
            @title = response[:title]
            @posters = response[:posters]
            @id = response[:id]
            @category = category
            @subdomains = GeeklistWS::Frontend::Subdomains.create_subdomains
            @poster = user
            @prepared_user = prepare_user(user) unless user.nil?
            @url = url
    	end

        def id
            @id
        end
        
        def user
            @prepared_user.nil? ? @poster : @prepared_user[:name]
        end

        def title
            return "#{@subdomains[@category.to_sym][:sub_name]} :: #{@title}" unless @category.nil? || @category.empty?
            @title
        end

        def category
            @category
        end

        def subdomains
            @subdomains
        end

        def url
            @url
        end

    	def headers
    		["Id","Title", "Poster", "Average Rating", "Overall Rank", "Average Weight"]
    	end

    	def games
    		prapared_games = []
    		@games.each do |game|
                prepared_game = {
    				:number => { :number => game[:number], :itemid => game[:itemid], :id => game[:id] },
    				#:title => create_title(game[:id], game[:title], game[:imageid]),
                    #:title => game[:title],
                    #:url => "http://www.boardgamegeek.com/boardgame/#{game[:id]}",
                    #:image => "http://cf.geekdo-images.com/images/pic#{game[:id]}_t.jpg",
    				:poster => { :name => game[:poster], :avatar => @posters[game[:poster]][:avatar] },
    				:average => create_max_float(game[:average], true),
    				:boardgame => create_max_int(game[:boardgame], true),
                    :averageweight => create_max_float(game[:averageweight], false),
                    :desc => create_desc(game),
                    :collection => create_collection(game[:id]),
                    :actual => check_actual(game[:body]),
                    :players => prepare_players(game),
                    :thumbs => create_max_int(game[:thumbs], false)
    			}
                prepared_game[:desc][:alias] = prepare_alias(prepared_game)
                prapared_games << prepared_game if check_category(prepared_game[:desc])
    		end
    		prapared_games
    	end

        def check_actual(body)
            body.nil? ? false : !body.downcase.include?("nieaktualne")
        end

        def check_category(description)
            case @category
                when "abstracts"
                    description[:ranks].has_key?("Abstract Game Rank")
                when "childrensgames"
                    description[:ranks].has_key?("Children's Game Rank")
                when "cgs"
                    description[:ranks].has_key?("Customizable Rank")
                when "familygames"
                    description[:ranks].has_key?("Family Game Rank")
                when "partygames"
                    description[:ranks].has_key?("Party Game Rank")
                when "strategygames"
                    description[:ranks].has_key?("Strategy Game Rank")
                when "thematic"
                    description[:ranks].has_key?("Thematic Game Rank")
                when "wargames"
                    description[:ranks].has_key?("War Game Rank")
                else
                    true
            end
        end

        def create_collection(id)
            collection = []
            if !@prepared_user.nil?
                if !@prepared_user[:collection].nil? && !@prepared_user[:collection][id].nil?
                    @prepared_user[:collection][id].each do |key, value|
                     collection << key unless value != "1"
                    end
                end
            end
            (collection.nil? || collection.empty?) ? nil : collection
        end

        def create_desc(game)
            description = { :ranks => {}, :children => []}
            description[:url] = "http://www.boardgamegeek.com/boardgame/#{game[:id]}"
            description[:image] = "http://cf.geekdo-images.com/images/pic#{game[:imageid]}_t.jpg"
            description[:title] = game[:title]
            stripped_body = game[:body].nil? ? "" : game[:body].gsub(/\[\/?[^\]]+\]/, '')
            if stripped_body.length > 75
                description[:short] = "#{stripped_body[0..75]}..."
            else
                description[:short] = stripped_body
            end
            description[:full] = stripped_body
            game.each do |key,value|
                if @subdomains.has_key?(key)
                    description[:ranks][@subdomains[key][:rank_name]] = value unless value == 0
                end
            end
            if !game[:children].nil? && !game[:children].empty?
                game[:children].each do |child|
                    description[:children] << create_child(child) unless child[:title].nil?
                end
            end
            description
        end

        def create_child(raw_child)
            child = {}
            child[:id] = raw_child[:id]
            child[:url] = "http://www.boardgamegeek.com/boardgame/#{raw_child[:id]}"
            child[:image] = raw_child[:thumb_url]
            child[:title] = raw_child[:title]
            child
        end

    	def create_max_float(number, ismax)
    		if number.to_f > 0 
    			return number.to_f
    		else 
                if ismax
    			    return 99999.to_f
                else
                    return 0.to_f
                end
    		end
    	end

        def create_max_int(number, ismax)
            if number.to_i> 0 
                return number.to_i
            else 
                if ismax
                    return 99999
                else
                    return 0
                end
            end
        end

        def prepare_players(game)
            players_string = game[:minplayers]
            players_string = players_string + " - #{game[:maxplayers]}" unless game[:maxplayers].nil?
            players_string
        end

        def prepare_user(user)
            @posters_repository = GeeklistWS::API::PostersRepository.new false
            readed_user = @posters_repository.one_user_in_repo(user)
            if !readed_user.nil?
                puts "User in posters repo"
            else
                puts "User not found"
                poster_collection = GeeklistWS::API::Readers.read_posters_collection(user)
                unless poster_collection.nil?
                   @posters_repository.add_user(user, poster_collection)
                   readed_user = { :name => user, :collection => poster_collection}
                end
            end
            readed_user
        end

        def prepare_alias(game)
            result = "%A#{game[:number][:id]}"
            game[:desc][:children].each do |child|
                result = "#{result}C#{child[:id]}"
            end
            result
        end
    end
  end
end