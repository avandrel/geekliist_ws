# encoding UTF-8

require 'nokogiri'
require 'open-uri'

module GeeklistWS
  module API
	class Readers
	  	def self.read_geeklist(id)
	  		list_repository = ListRepository.new
	  		if list_repository.list_in_repo?(id)
	  			puts "List from cache"
	  			list = list_repository.get_list(id)
	  		else
	  			puts "List from BGG"
	  			list = open("http://www.boardgamegeek.com/xmlapi/geeklist/#{id}").read
	  			list_repository.add_list(id, list)
	  		end
	  		doc = Nokogiri::HTML(list, nil, "UTF-8")
	  		geeklist = {:games => []}
	  		geeklist[:title] = doc.at_xpath("//title").content
	  		geeklist[:id] = doc.at_xpath("//geeklist").attribute('id').value
	  		doc.xpath("//item").each do |item|
	  			geeklist[:games] << Parsers.parse_item(item, geeklist[:games].length + 1)
	  		end
	  		geeklist
	  	end

	  	def self.read_game(game)
	  		doc = Nokogiri::HTML(open("http://www.boardgamegeek.com/xmlapi/boardgame/#{game[:id]}?stats=1"))
	  		ratings = doc.xpath("//boardgames/boardgame/statistics/ratings")
	  		game.merge(Parsers.parse_rating(ratings))
	  	end

	  	def self.read_poster(name)
	  		doc = Nokogiri::HTML(open(URI.encode("http://www.boardgamegeek.com/xmlapi2/user?name=#{name}")))
	  		doc.at_xpath("//avatarlink").attribute('value').value
	  	end

	  	def self.read_results(id)
	  		results_repository = ResultsRepository.new
	  		if results_repository.result_in_repo?(id)
	  			result = results_repository.get_result(id)
	  			result
	  		else
		  		file = open("https://dl.dropboxusercontent.com/u/17622107/MatHandel%20%2319,5%20-%20Wyniki.txt")
		  		trades = []
		  		file.readlines.each do |line|
					scaned_line = line.scan(/[(](\w+)[)]\s(\d+)\s+receives\s[(](\w+)[)]\s+(\d+)\s+and sends to\s[(](\w+)[)]\s+(\d+)/)
					unless scaned_line.empty? 
						trades << { :item => { :user_id => scaned_line[0][0], :game_id => scaned_line[0][1] }, 
											:receives => { :user_id => scaned_line[0][2], :game_id => scaned_line[0][3] },
											:sends => { :user_id => scaned_line[0][4], :game_id => scaned_line[0][5] }
										}
					end
					scaned_line = line.scan(/[(](\w+)[)]\s(\d+)\s+does not trade/)
					unless scaned_line.empty?
						trades << { :item => { :user_id => scaned_line[0][0], :game_id => scaned_line[0][1] } }			
					end
				end
				{ :id => id, :items => trades }
			end
	  	end
	end
  end
end