class AlterRresetsUseStringsNotIntegers < ActiveRecord::Migration
  def self.up
    # These had no real reason being integers, and this will be more adaptive to Flickr changing what it returns
    change_column :rresets, :flickr_farm,    :string
    change_column :rresets, :flickr_primary, :string
    change_column :rresets, :flickr_server,  :string
  end

  def self.down
    change_column :rresets, :flickr_farm,    :integer
    change_column :rresets, :flickr_primary, :integer
    change_column :rresets, :flickr_server,  :integer
  end
end
