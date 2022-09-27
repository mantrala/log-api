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

  def test_query_with_nocase
    f = Services::CriblFile.new(LOG_LOCATION, {:filename => 'sample-1.log', :q => 'mailBOX_register'})

    assert_equal 4, f.process.size
  end

  def test_query_with_case
    f = Services::CriblFile.new(LOG_LOCATION, {:filename => 'sample-1.log', :q => 'mailBOX_register', :ignore_case => :false})

    assert_equal 0, f.process.size
  end

  def test_last_new_lines
    f = Services::CriblFile.new(LOG_LOCATION, {:filename => 'test.log', :lines => 1})
    data = f.process

    assert_equal 1, data.size
    assert_equal ['line 3'], data
  end

  def test_ensure_all_chars_show_up
    f = Services::CriblFile.new(LOG_LOCATION, {:filename => 'test.log'})
    data = f.process

    assert_equal 3, data.size
    assert_equal ['line 3', 'line 2', 'line 1'], data

  end
end

