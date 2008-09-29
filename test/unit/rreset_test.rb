require 'test_helper'

class RresetTest < ActiveSupport::TestCase
  context 'A Rreset instance in general' do
    setup do
      setup_new_rreset_scenario
    end
    
    should_change "Rreset.count", :by => 1
    should_belong_to :user
    should_require_attributes :user_id, :flickr_farm, :flickr_photos, :flickr_primary, :flickr_server, :flickr_secret, :flickr_id
    
  end
  
  context 'A Rreset syncing with Flickr' do
    setup { setup_new_rreset_scenario }
    
    should 'not need syncing with flickr because it is brand new'  do
      assert !@rreset.needs_syncing?
    end
    
    should 'should not sync if not out of date when found with self.find_by_flickr_id_and_sync!' do
      found_again = Rreset.find_by_flickr_id_and_sync!(@rreset.flickr_id)
      assert_equal @rreset.updated_at.to_s, found_again.updated_at.to_s 
    end
    
    context "when it is out of date" do
      setup do
        @change_to = 5.hours.ago
        # To change set the updated_at in the past we have to turn off automatic timestamping
        Rreset.record_timestamps = false
        @rreset.update_attribute(:updated_at, @change_to)
        Rreset.record_timestamps = true
      end
      
      should 'need syncing' do
        assert @rreset.needs_syncing?
      end
      
      should 'update itself when told to sync' do
        mock_flickr_call('flickr_photosets_get_info')
        Rreset.any_instance.stubs(:valid?).returns(true) # It would be invalid otherwise because the mock called photoset isn't owned by the same person.
        updated = @rreset.sync_with_flickr!
        assert_instance_of Rreset, updated
        assert_not_equal @rreset.reload.updated_at.to_s, @change_to.to_s
      end
      
      should 'sync itself with Flickr when found with self.find_by_flickr_id_and_sync!' do
        mock_flickr_call('flickr_photosets_get_info')
        Rreset.any_instance.stubs(:valid?).returns(true)
        found_again = Rreset.find_by_flickr_id_and_sync!(@rreset.flickr_id)
        assert_not_equal @rreset.updated_at.to_s, found_again.updated_at.to_s
      end
    end
  end
  
  context 'Rreset.find_by_flickr_id_and_sync!' do
    should "raise an exception if it can't find a record" do
      assert_raises ActiveRecord::RecordNotFound do
        Rreset.find_by_flickr_id_and_sync!(999999999999999999999999999999999999999)
      end
    end
  end

private

  def setup_new_rreset_scenario
    @rreset = Factory.build(:rreset)
    Flickr.stubs(:photosets_get_photos).with("#{@rreset.flickr_id}").returns([{:id => '2620994337'}])
    @rreset.save!
  end
end
