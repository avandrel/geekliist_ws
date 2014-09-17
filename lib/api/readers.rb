# encoding UTF-8

require 'nokogiri'
require 'open-uri'

module GeeklistWS
  module API
	class Readers
	  	def self.read_geeklist(id)
	  		@list_repository = ListRepository.new
	  		if @list_repository.list_in_repo?(id)
	  			puts "List from cache"
	  			list = @list_repository.get_list(id)
	  		else
	  			puts "List from BGG"
	  			list = open("http://www.boardgamegeek.com/xmlapi/geeklist/#{id}").read
	  			@list_repository.add_list(id, list)
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
	end
  end
end