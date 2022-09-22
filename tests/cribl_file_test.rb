ENV['APP_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require_relative '../services/cribl_file.rb'
require_relative '../server.rb'

class CriblFileTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_exists?
    conditions = [
      ['sample-1.log', true, 'file exists'],
      ['does-not-exist.log', false, 'file does not exist'],
      [nil, false, 'nil filename'],
      ['   ', false, 'empty filename']
    ]

    conditions.each do |c|
      f = Services::CriblFile.new(LOG_LOCATION, {:filename => c[0]})
      assert_equal(c[1], f.exists?, c[2])
    end
  end

  def test_read
    f = Services::CriblFile.new(LOG_LOCATION, {:filename => 'sample-1.log', :lines => 2})
    original = [
      '03/22 08:51:06 INFO   :....mailbox_register: mailbox allocated for rsvp-udp',
      '03/22 08:51:06 TRACE  :..entity_initialize: interface 9.67.117.98, entity for rsvp allocated and'
    ]

    assert_equal original.reverse, f.process
  end

  def test_read_with_negative_lines
    f = Services::CriblFile.new(LOG_LOCATION, {:filename => 'sample-1.log', :lines => -2})

    assert_equal 10, f.process.size
  end
end

