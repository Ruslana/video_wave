require 'streamio-ffmpeg'
require 'rmagick'
class VideoFile < ApplicationRecord
  mount_uploader :file, VideoUploader
  after_save :watermark_stream

  private

  def watermark_stream
    create_watermark_image
    encode_video
    add_encode_file_url
  end

  def encode_video
    video = FFMPEG::Movie.new(file.path)
    options = { watermark: path_to_watermark, resolution: "320x240",
                watermark_filter: { position: "RT", padding_x: 10, padding_y: 10 } }
    video.transcode(path_to_encode_video, options)
    update_column :duration, video.duration
  end

  def create_watermark_image
    canvas = Magick::Image.new(500, 100){ self.background_color = 'Transparent' }
    gc = Magick::Draw.new
    gc.pointsize(25)
    gc.text(300, 70, watermark.center(14))
    gc.align = Magick::CenterAlign

    gc.draw(canvas)
    canvas.write(path_to_watermark)
  end

  def add_encode_file_url
    encode_file_url = file.url.gsub(file.file.filename, "encode-#{file.file.filename}")
    update_column :encode_file_url, encode_file_url
  end

  def path_to_watermark
    path_to_field + 'watermark.png'
  end

  def path_to_encode_video
    path_to_field + 'encode-' + file.file.filename
  end

  def path_to_field
    Rails.root.join("public", "uploads", "video_file", "file", "#{id}/").to_s
  end
end
