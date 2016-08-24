Whacamole.configure("geeklistws") do |config|
  config.api_token = "34206007-7d78-4e2b-9c71-653fbb35c55a"
  config.restart_threshold = 500 # in megabytes. default is 1000 (good for 2X dynos)
  config.restart_window = 30*60 # restart rate limit in seconds. default is 30 mins.
end