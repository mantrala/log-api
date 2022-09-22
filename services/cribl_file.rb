module Services
  class CriblFile
    MAX_LINES = 10
    attr_accessor :filename, :location
    attr_reader :default_lines

    def initialize(location, params)
      @location = location
      @filename = params[:filename]
      @default_lines = params[:lines].to_i || MAX_LINES
      @default_lines = MAX_LINES if @default_lines.to_i <= 0
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

      data = read
      data.split("\n").reverse
    end


    private

    # simple implementation of tail
    def read
      pos = 0
      line = 0

      loop do
        pos -= 1
        fd.seek(pos, IO::SEEK_END)
        char = fd.read(1)

        if line_break?(char)
          line += 1
        end

        break if line >= default_lines || fd.tell == 0
      rescue StandardError
        break # no more lines to read
      end

      fd.read
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
