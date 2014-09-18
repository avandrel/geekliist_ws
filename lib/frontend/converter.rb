module GeeklistWS
  module Frontend
    class Converter
    	def initialize(response, category)
    		@games = response[:games]
            @title = response[:title]
            @posters = response[:posters]
            @id = response[:id]
            @category = category
            @subdomains = GeeklistWS::Frontend::Subdomains.create_subdomains
    	end

        def id
            @id
        end
        
        def title
            return "#{@subdomains[@category.to_sym][:sub_name]} :: #{@title}" unless @category.empty?
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
    				:poster => { :name => game[:poster], :avatar => @posters[game[:poster]] },
    				:average => create_number(game[:average]),
    				:boardgame => create_number(game[:boardgame]),
                    :desc => create_desc(game),
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

        def create_desc(game)
            description = { :ranks => {}}
            description[:url] = "http://www.boardgamegeek.com/boardgame/#{game[:id]}"
            description[:image] = "http://cf.geekdo-images.com/images/pic#{game[:imageid]}_t.jpg"
            description[:title] = game[:title]

            game.each do |key,value|
                if @subdomains.has_key?(key)
                    description[:ranks][@subdomains[key][:rank_name]] = value unless value == 0
                end
            end
            description
        end

    	def create_number(number)
    		if number.to_i > 0 
    			return number
    		else
    			return "---"
    		end
    	end
    end
  end
end