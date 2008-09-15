module PhotosHelper
  def photo_title(photo)
    photo[:title].blank? ? 'untitled' : photo[:title]
  end
  
  def photo_owner(owner_hash)
    [:realname, :username].each do |key|
      return owner_hash[key] unless owner_hash[key].blank?
    end
  end
end
