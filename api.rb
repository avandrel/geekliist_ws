module GeeklistWS
  class API < Grape::API
    format :json

    namespace :geeklist do
      get "/:id", requirements: { id: /[0-9]*/ } do
      	start_time = Time.now
      	puts "Start reading from BGG"
        geeklist = GeeklistWS::Readers.read_geeklist(params[:id])
        puts "Geeklist loaded"
        games_finder = GamesFinder.new geeklist
        response = games_finder.find_games
        puts "\nName: #{geeklist[:title]}, Elapsed: #{Time.now - start_time}s, Count: #{response.length}"
        response
      end
    end
  end

  class GamesFinder
  	def initialize(geeklist)
  		@geeklist = geeklist
  	end

  	def find_games
  		@repository = Repository.new
  		games = []
  		puts "Reading"
  		@geeklist[:games].each do |game|
  			print_and_flush(".")
  			if @repository.game_in_repo?(game[:id])
  				#puts "Reading from repo #{game[:id]}"
  				games << @repository.get_game(game)
  			else
  				#puts "Reading from BGG #{game[:id]}"
  				readed_game = Readers.read_game(game)
  				@repository.add_game(readed_game)
  				readed_game.delete("_id") if readed_game.has_key?("_id")
  				games << readed_game
  			end
  		end
  		games
  	end

    def print_and_flush(str)
  		print str
  		$stdout.flush
	end
  end

  class Repository
  	def initialize
  		connector = MongoConnector.new 
  		@games_collection = connector.games_collection
  	end

  	def game_in_repo?(id)
  		@games_collection.find_one({:id => "#{id}"}) != nil
  	end

  	def add_game(game)  		
  		game.delete(:poster) unless game[:poster] == nil
  		@games_collection.insert(game)
  	end

  	def get_game(game)
  		game[:rating] = @games_collection.find_one({:id => "#{game[:id]}"}, {:fields => [:rating]})
  		game[:rating].delete("_id") if game[:rating].has_key?("_id")
  		game
  	end
  end

  class Readers
  	def self.read_geeklist(id)
  		doc = Nokogiri::HTML(open("http://www.boardgamegeek.com/xmlapi/geeklist/#{id}"))
  		geeklist = {:games => []}
  		geeklist[:title] = doc.at_xpath("//title").content
  		doc.xpath("//item").each do |item|
  			geeklist[:games] << Parsers.parse_item(item, geeklist[:games].length + 1)
  		end
  		geeklist
  	end

  	def self.read_game(game)
  		doc = Nokogiri::HTML(open("http://www.boardgamegeek.com/xmlapi/boardgame/#{game[:id]}?stats=1"))
  		ratings = doc.xpath("//boardgames/boardgame/statistics/ratings")
  		game[:rating] = Parsers.parse_rating(ratings)
  		game
  	end
  end

  class Parsers
  	def self.parse_item(item, number)
  		game = {}
  		game[:id] = item.attribute('objectid').value
  		game[:title] = item.attribute('objectname').value
  		game[:poster] = item.attribute('username').value
  		game[:number] = number
		game
  	end

  	def self.parse_rating(rating)
  		hash_rating = {}
  		hash_rating[:average] = rating.at_xpath("//average").content
  		rating.xpath("//ranks/rank").each do |rank|
  			hash_rating[rank.attribute('name').value.to_sym] = rank.attribute('value').value.to_i
  		end
  		hash_rating
  	end
  end

  class MongoConnector
  	def connect
  		Mongo::Connection.new("localhost").db("geeklistws")
  	end
  	
  	def games_collection
  		connect["games"]
  	end
  end

end
