require 'sinatra'
require 'sinatra/json'

require_relative './services/cribl_file.rb'

LOG_LOCATION = '/var/log'
MAX_FILES_RETURNED = 10

class Server < Sinatra::Base
  get '/api/v1/logs' do
    if params.empty?
      # return only 10 files?
      files = []
      Dir.entries(LOG_LOCATION).each do |f|
        if File.file?(File.join(LOG_LOCATION, f))
          break if files.length >= MAX_FILES_RETURNED
          files << f
        end
      end

      return json(:files => files)
    end

    f = Services::CriblFile.new(LOG_LOCATION, params)
    if f.exists?
      json(:data => f.process)
    else
      status 404
      return json(:error => 'File not found')
    end
  end
end
