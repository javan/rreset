class AddNewestFlickrPhotoIdToRresets < ActiveRecord::Migration
  def self.up
    add_column :rresets, :newest_flickr_photo_id, :string
  end

  def self.down
    remove_column :rresets, :newest_flickr_photo_id
  end
end
