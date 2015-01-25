# encoding UTF-8

module GeeklistWS
  module Frontend
    class ListConverter
    	def initialize(response, category, user)
    		@games = response[:games]
            @title = response[:title]
            @posters = response[:posters]
            @id = response[:id]
            @category = category
            @subdomains = GeeklistWS::Frontend::Subdomains.create_subdomains
            @user = user
            @prepared_user = prepare_user(user) unless @user.nil? && !@posters[@user].nil?
    	end

        def id
            @id
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

    	def headers
    		["Id","Title", "Poster", "Average Rating", "Overall Rank"]
    	end

    	def games
    		prapared_games = []
    		@games.each do |game|
                prepared_game = {
    				:number => { :number => game[:number], :itemid => game[:itemid] },
    				#:title => create_title(game[:id], game[:title], game[:imageid]),
                    #:title => game[:title],
                    #:url => "http://www.boardgamegeek.com/boardgame/#{game[:id]}",
                    #:image => "http://cf.geekdo-images.com/images/pic#{game[:id]}_t.jpg",
    				:poster => { :name => game[:poster], :avatar => @posters[game[:poster]][:avatar] },
    				:average => create_number(game[:average]),
    				:boardgame => create_number(game[:boardgame]),
                    :desc => create_desc(game),
                    :collection => create_collection(game[:id]),
                    :actual => check_actual(game[:body])
    			}
                prapared_games << prepared_game if check_category(prepared_game[:desc])
    		end
    		prapared_games
    	end

        def check_actual(body)
            !body.downcase.include?("nieaktualne")
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
            if !@user.nil? && !@posters[@user].nil? && !@posters[@user][:collection].nil? && !@posters[@user][:collection][id].nil?
                @posters[@user][:collection][id].each do |key, value|
                    collection << key unless value != "1"
                end
            end
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
            stripped_body = game[:body].gsub(/\[\/?[^\]]+\]/, '')
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
            child[:url] = "http://www.boardgamegeek.com/boardgame/#{raw_child[:id]}"
            child[:image] = raw_child[:thumb_url]
            child[:title] = raw_child[:title]
            child
        end

    	def create_number(number)
    		if number.to_i > 0 
    			return number
    		else
    			return "---"
    		end
    	end

        def prepare_user(user)
            if @posters[@user].nil?
                @posters_repository = GeeklistWS::API::PostersRepository.new false
                readed_poster = @posters_repository.one_poster_in_repo(user)
                if !readed_poster.nil?
                    puts "User in posters repo"
                    if readed_poster[:collection].nil?
                        poster_collection = GeeklistWS::API::Readers.read_posters_collection(user)
                        unless poster_collection.nil?
                            readed_poster[:collection] = poster_collection
                            @posters_repository.update_poster(readed_poster)
                        end
                    end
                else
                    puts "User not found"
                    avatar = GeeklistWS::API::Readers.read_poster(user)
                    avatar = "http://mathtrade.mgpm.pl/img/meeple.png" unless avatar != "N/A"
                    poster_collection = GeeklistWS::API::Readers.read_posters_collection(user)
                    @posters_repository.add_poster(user, avatar, poster_collection)
                    readed_poster = { :name => user, :avatar => avatar, :collection => poster_collection}
                end
            end
            readed_poster
        end
    end
  end
end