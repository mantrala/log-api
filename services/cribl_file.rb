module Services
  class CriblFile
    MAX_LINES = 10

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

      queried_data = []
      page_size = default_lines
      searched_lines = 0

      while queried_data.size <= default_lines
        data, done = read(page_size)
        data = data.split("\n").reverse

        # should we limit the size of the query?
        return data if q.nil? || q.strip.length <= 0

        data = data[searched_lines..page_size]
        data.each do |l|
          add_line = false
          if ignore_case && l =~ /#{q}/i
            add_line = true
          elsif l =~ /#{q}/
            add_line = true
          end

          queried_data << l if add_line && queried_data.size < default_lines
        end

        break if done || queried_data.size == default_lines

        searched_lines = page_size
        page_size += MAX_LINES
      end

      queried_data
    end

    private

    # simple implementation of tail
    def read(lines_to_read)
      pos = 0
      line = 0

      loop do
        pos -= 1
        fd.seek(pos, IO::SEEK_END)
        char = fd.read(1)

        if line_break?(char)
          line += 1
        end

        break if line >= lines_to_read || fd.tell == 0
      rescue StandardError
        return [fd.read, true] # no more lines to read
      end

      [fd.read, false]
    end

    def fd
      @fd ||= File.open(file_path)
    end

    def file_path
      File.join(location, filename)
    end

    # could filename be encoded when stored?
    def invalid?
      true if filename.nil? || filename.strip == ""
    end

    def line_break?(char)
      char == "\n"
    end
  end
end
