require 'pry'
require 'pry-byebug'

module Services
  class CriblFile
    MAX_LINES = 10
    PAGE_SIZE = 1024 * 64

    attr_accessor :filename, :location
    attr_reader :default_lines, :q, :ignore_case

    def initialize(location, params)
      # could move parsing to a new class with it's own responsibilities
      @location = location
      @filename = params[:filename]
      @default_lines = params[:lines].to_i || MAX_LINES
      @default_lines = MAX_LINES if @default_lines.to_i <= 0

      @q = params[:q]
      @ignore_case = params[:ignore_case]&.to_sym == :false ? false : true
    end

    def exists?
      @valid ||= begin
        return false if invalid?
        # should we allow accessing any directories?
        File.file?(file_path)
      end
    end

    def process
      return unless exists?

      data = tail(file_path, default_lines)

      # should we limit the size of the query?
      return data if q.nil? || q.strip.length <= 0

      queried_data = []
      data.each do |l|
        if ignore_case && l =~ /#{q}/i
          queried_data << l
        elsif l =~ /#{q}/
          queried_data << l
        end
      end

      queried_data
    end


    private

    def file_path
      File.join(location, filename)
    end

    # could filename be encoded when stored?
    def invalid?
      true if filename.nil? || filename.strip == ""
    end

    def tail(fname, lines)
      File.open(fname) do |file|
        offset = file_offset(file, lines, "\n")
        file.seek(file.size - offset)
        return file.read.split("\n").reverse
      end

    end

    def file_chunks(file, size)
      num_chunks = file.size / size
      num_chunks -= 1 if file.size == num_chunks * size
      len = file.size - num_chunks * size
      until num_chunks < 0
        file.seek(num_chunks * size)
        yield file.read(len)
        num_chunks -= 1
        len = size
      end
    end

    def file_offset(file, line_count, line_separator)
      offset = 0
      file_chunks(file, PAGE_SIZE) do |chunk|
        chunk.size.times do |i|
          chr = chunk[chunk.size - i - 1]
          if chr == line_separator || (offset == 0 && i == 0 && chr != line_separator)
            line_count -= 1

            if line_count < 0
              offset += i
              return offset
            end
          end
        end
        offset += chunk.size
      end

      offset
    end
  end
end
