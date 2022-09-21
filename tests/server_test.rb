ENV['APP_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require_relative '../server.rb'

class ServerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_returns_all_files
    get '/api/v1/logs'
    assert last_response.ok?
    b = JSON.parse(last_response.body)
    assert_equal 10, b['files'].size
  end
end
