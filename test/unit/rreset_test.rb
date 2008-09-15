require 'test_helper'

class RresetTest < ActiveSupport::TestCase
  context 'A Rreset instance in general' do
    setup do
      @rreset = Factory.build(:rreset)
      Flickr.stubs(:photosets_get_photos).with("#{@rreset.flickr_id}").returns([{:id => '2620994337'}])
      @rreset.save!
    end
    
    should_change "Rreset.count", :by => 1
    should_belong_to :user
    should_require_attributes :user_id, :flickr_farm, :flickr_photos, :flickr_primary, :flickr_server, :flickr_secret, :flickr_id
  end
end
