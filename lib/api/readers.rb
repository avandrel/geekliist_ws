require 'nokogiri'
require 'open-uri'

module GeeklistWS
  module API
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
	  		game.merge(Parsers.parse_rating(ratings))
	  	end
	end
  end
end