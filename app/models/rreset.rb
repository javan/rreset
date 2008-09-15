# == Schema Information
# Schema version: 20080909233215
#
# Table name: rresets
#
#  id                     :integer(11)     not null, primary key
#  user_id                :integer(11)     
#  flickr_farm            :string(255)     
#  flickr_photos          :integer(11)     
#  flickr_primary         :string(255)     
#  flickr_title           :string(255)     
#  flickr_description     :text            
#  flickr_server          :string(255)     
#  flickr_secret          :string(255)     
#  flickr_id              :string(255)     
#  created_at             :datetime        
#  updated_at             :datetime        
#  newest_flickr_photo_id :string(255)     
#

class Rreset < ActiveRecord::Base
  belongs_to :user
  attr_accessor :flickr_owner
  attr_readonly :flickr_id, :created_at
  
  validates_presence_of :user_id, :flickr_farm, :flickr_photos, :flickr_primary, :flickr_server, :flickr_secret, :flickr_id, :newest_flickr_photo_id
  validate :user_owns_set
  before_validation_on_create :set_newest_flickr_photo_id
  
  def image_path(size = :m)
    "http://farm#{flickr_farm}.static.flickr.com/#{flickr_server}/#{flickr_primary}_#{flickr_secret}_#{size}.jpg"
  end
  
  def self.find_with_update_by_flickr_id!(flickr_id, *args)
    rreset = find_by_flickr_id(flickr_id, *args)
    raise ActiveRecord::RecordNotFound unless rreset
    
    # If it hasn't been updated recently, call Flickr to see if any attributes have changed
    if rreset.updated_at < 3.hours.ago
      updated_set = Flickr.photosets_get_info(rreset.flickr_id)
      new_rreset  = rreset.user.rresets.build(updated_set.prefix_keys_with('flickr_'))
      rreset.flickr_owner ||= rreset.user.flickr_nsid
      rreset.update_attributes!(new_rreset.attributes) if new_rreset.valid?
    end
    
    rreset
  end
  
private
  
  # Validation to ensure that the set being added actually belongs to the user
  def user_owns_set
    errors.add_to_base('The set your are trying to add does not belong to you. You may only adds sets that you have created.') if flickr_owner.to_s != user.flickr_nsid.to_s
  end
  
  def set_newest_flickr_photo_id
    self.newest_flickr_photo_id = Flickr.photosets_get_photos("#{self.flickr_id}").last[:id] if self.flickr_id
  end
end
