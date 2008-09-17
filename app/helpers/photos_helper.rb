module PhotosHelper
  def photo_title(photo)
    photo[:title].blank? ? 'untitled' : photo[:title]
  end
  
  def photo_thumbnail(photo)
    image_tag("http://farm#{photo[:farm]}.static.flickr.com/#{photo[:server]}/#{photo[:id]}_#{photo[:secret]}_t.jpg", :alt => '')
  end
  
  def photo_owner(owner_hash)
    [:realname, :username].each do |key|
      return owner_hash[key] unless owner_hash[key].blank?
    end
  end
end
