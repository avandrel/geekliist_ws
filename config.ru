require 'mongo'
require 'newrelic_rpm'
require 'rack/cache'

Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|f| require f}

NewRelic::Agent.manual_start
use Rack::Deflater
use Rack::Cache,
      :metastore   => 'file:/var/cache/rack/meta',
      :entitystore => 'file:/var/cache/rack/body',
      :verbose     => true
use Rack::Static, 
  :urls => ["/public/img", "/public/js", "/public/css"]
run Rack::Cascade.new [GeeklistWS::API::Api, GeeklistWS::Frontend::Web]