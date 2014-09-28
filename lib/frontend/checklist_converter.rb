# encoding UTF-8

module GeeklistWS
  module Frontend
    class CheckListConverter
    	def initialize(response)
            @subdomains = GeeklistWS::Frontend::Subdomains.create_subdomains
            @id = response[:id]
            @exchanges = sort_games(response[:exchanges])
            create_exchanges
    	end

        def id
            @id
        end

        def subdomains
            @subdomains
        end

        def exchanges
            @flatten_exchanges
        end

    	def headers
    		["Id","Title", "Poster", "Average Rating", "Overall Rank"]
    	end

        def sort_games(exchanges)
            exchanges[0].each do |exchange|
                exchange[:to].each do |prio|
                    prio.delete_if {|hsh| hsh.nil?}
                    prio.sort_by! { |hsh| hsh[:title] } unless prio.nil?
                end
            end
            exchanges
        end

        def create_exchanges
            @flatten_exchanges = []
            @exchanges[0].each do |exchange|
                flat_ex = { :poster => exchange[:poster] }
                flat_ex[:from] = exchange[:from]
                flat_ex[:to] = exchange[:to]
                @flatten_exchanges << flat_ex
            end
        end

    	def games(priorities)
    		prapared_games = []
    		priorities.each do |game|
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

        def create_desc(game)
            description = { :ranks => {}}
            description[:url] = "http://www.boardgamegeek.com/geeklist/#{@id}/item/#{game[:itemid]}#item#{game[:itemid]}"
            description[:image] = "http://cf.geekdo-images.com/images/pic#{game[:imageid]}_t.jpg"
            description[:title] = game[:title]
            description[:number] = game[:number]
            description[:aliases] = game[:aliases]
            description[:actual] = check_actual(game[:body])
            puts description[:body]

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