module GeeklistWS
  module Frontend
    class Subdomains
    	def self.create_subdomains
    		subdomains = {}
    		subdomains[:abstracts] = { :rank_name => "Abstract Game Rank", :sub_name => "Abstract Games" }
            subdomains[:childrensgames] = { :rank_name => "Children's Game Rank", :sub_name => "Children's Games" }
            subdomains[:cgs] = { :rank_name => "Customizable Rank", :sub_name => "Customizable Games" }
            subdomains[:familygames] = { :rank_name => "Family Game Rank", :sub_name => "Family Games" }
            subdomains[:partygames] = { :rank_name => "Party Game Rank", :sub_name => "Party Games" }
            subdomains[:strategygames] = { :rank_name => "Strategy Game Rank", :sub_name => "Strategy Games" }
            subdomains[:thematic] = { :rank_name => "Thematic Game Rank", :sub_name => "Thematic Games" }
            subdomains[:wargames] = { :rank_name => "War Game Rank", :sub_name => "War Games" }
            subdomains
    	end
    end
  end
end