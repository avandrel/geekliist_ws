# encoding UTF-8

module GeeklistWS
  module API
    class Stats
	  def self.create_stats(id)
	  	wants = get_wants(id)
	  	results = get_results(id)
	  	stats = []
	  	stats << find_most_wanted(wants)
	  	stats
	  end

	  def self.get_results(id)
	  	results_repository = ResultsRepository.new
	  	results_repository.get_result(id)
	  end

	  def self.get_wants(id)
	  	wants_repository = WantlistRepository.new
	  	wants_repository.get_wantlist(id)
	  end

	  def self.find_most_wanted(wants)
	  	to_collection = []
	  	result_collection = {}
	  	wants[:wantlist].group_by{|want| want[:poster]}.each do |poster, posters_group|
	  		#puts posters_group.inspect
	  		posters_to = []
	  		posters_group.each do |group|
	  			group[:to].each do |to|
	  				posters_to = posters_to | to
	  			end
	  		end
	  		posters_to.each do |elem|
  				if result_collection[elem].nil?
  					result_collection[elem] = 1 
  				else
  					result_collection[elem] += 1 
  				end
  			end
	  	end
	  	result_collection.sort_by{ |k,v| v}.reverse.first
	  end
    end
  end
end