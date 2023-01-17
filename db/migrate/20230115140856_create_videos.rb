class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.integer :duration
      t.integer :bitrate
      t.datetime :create_time
      t.string :author
      t.integer :number_of_comments
      t.integer :number_of_hearts
      t.integer :number_of_plays
      t.integer :number_of_reposts
      t.string :url

      t.timestamps
    end
  end
end
