require 'nokogiri'
require 'open-uri'

module GeeklistWS
  module Frontend
	class Readers
		def self.read_games(id)
	  		Nokogiri::HTML(open("http://localhost:9292/geeklist/#{id}"))
	  	end
	end
  end
end