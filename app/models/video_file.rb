class VideoFile < ApplicationRecord
  mount_uploader :file, VideoUploader
  after_save :watermark_stream

  def encode_file
    @encode_file_url ||= file.url.gsub(file.file.filename, "#{time_hash}-#{file.file.filename}")
  end

  private

  def time_hash
    @time_hash ||= Time.now.to_i
  end

  def watermark_stream
    movie = FFmpeg.new(file.path, path_to_encode_video, watermark)
    movie.encode
    update_column :duration, movie.duration.to_i
    update_column :encode_file_url, encode_file
  end

  def path_to_encode_video
    Rails.root.join("public").to_s + encode_file
  end
end
