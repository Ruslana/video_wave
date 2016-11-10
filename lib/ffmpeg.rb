class FFmpeg
  attr_reader :duration

  def initialize(input_file, output_file, watermark)
    @input_file = input_file
    @output_file = output_file
    @watermark = watermark
  end

  def encode
    Open3.popen3(attributes) do |stdin, stdout, stderr, _wait_thr|
      @duration = 0
      stderr.each("\r") do |line|
        next unless (line.include?("time=") || line.include?("Duration:"))
        if @duration == 0
          if line =~ /Duration:\s+(\d{2}):(\d{2}):(\d{2}).(\d{1,2})/
            @duration = $1.to_i * 3600 + $2.to_i * 60 + $3.to_i
          end
        end
      end
    end
    self
  rescue Errno::ENOENT => e
    Rails.logger.error "Error: #{e}"
  end

  private

  def attributes
    [ffmpeg, '-i', @input_file, '-vf', drawtext, @output_file].join(' ')
  end

  def drawtext
    "drawtext=\"fontfile=#{fontfile}:text='#{@watermark}':x=(w-text_w)/2:y=(h-text_h)/2\""
  end

  def fontfile
    "#{Dir.home}/Library/Fonts/DejaVuSans.ttf"
  end

  def ffmpeg
    find_executable 'ffmpeg'
  end
end
