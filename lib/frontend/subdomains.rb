module GeeklistWS
  module Frontend
    class Subdomains
    	def self.create_subdomains
    		subdomains = {}
    		subdomains[:abstracts] = "Abstract Game Rank"
            subdomains[:childrensgames] = "Children's Game Rank"
            subdomains[:cgs] = "Customizable Rank"
            subdomains[:familygames] = "Family Game Rank"
            subdomains[:partygames] = "Party Game Rank"
            subdomains[:strategygames] = "Strategy Game Rank"
            subdomains[:thematic] = "Thematic Game Rank"
            subdomains[:wargames] = "War Game Rank"
            subdomains
    	end
    end
  end
end