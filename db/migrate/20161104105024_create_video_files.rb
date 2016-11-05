class CreateVideoFiles < ActiveRecord::Migration
  def change
    create_table :video_files do |t|
      t.string :file
      t.string :watermark
      t.string :encode_file_url
      t.integer :duration

      t.timestamps
    end
  end
end
