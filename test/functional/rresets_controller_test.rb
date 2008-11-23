require 'test_helper'

class RresetsControllerTest < ActionController::TestCase

  should_require_authentication 'post :create'
  should_require_authentication 'delete :destroy, :id => 1'
  
  context 'Creating a new Rreset' do
    setup do
      setup_create_scenario
      post :create, :photoset_id => @photoset_id
    end
    
    should_set_the_flash_to /.*/
    should_redirect_to 'settings_path'
    should_change 'Rreset.count', :by => 1
  end
  
  context 'Creating a new Rreset via ajax' do
    setup do
      setup_create_scenario
      xhr :post, :create, :photoset_id => @photoset_id
    end
    
    should_respond_with :success
    should_render_template :create
    should_not_set_the_flash
    should_send_back_javascript
    should_change 'Rreset.count', :by => 1
  end
  
  context 'Destroying a Rreset (stop sharing it)' do
    setup do
      setup_destroy_scenario
      delete :destroy, :id => @rreset.id
    end
    
    should_set_the_flash_to /.*/
    should_redirect_to 'settings_path'
    
    should 'reduce the number of Rresets by 1' do
      assert_equal @count - 1, Rreset.count
    end
  end
  
  context 'Destroying a Rreset via ajax (stop sharing it)' do
    setup do
      setup_destroy_scenario
      xhr :delete, :destroy, :id => @rreset.id
    end
    
    should_respond_with :success
    should_render_template :destroy
    should_not_set_the_flash
    should_send_back_javascript
    
    should 'reduce the number of Rresets by 1' do
      assert_equal @count - 1, Rreset.count
    end
  end
  
  context 'Attempting to destroy a Rreset that does not belong to the owner' do
    setup do
      setup_destroy_scenario
      login_as(Factory.create(:user)) # Login is a different user
      delete :destroy, :id => @rreset.id
    end
    
    should 'not change the number of Rresets' do
      assert_equal Rreset.count, @count
    end
  end
  
  context 'Viewing the Rresets of a user with just one shared Rreset' do
    setup do
      expects_set_newest_flickr_photo_id do
        @rreset = Factory.create(:rreset)
      end
      @user = @rreset.user
      assert_equal 1, @user.rresets.size
      
      get :index, :nsid => @user.flickr_nsid
    end
    
    should_not_set_the_flash
    should_redirect_to "set_path(:set_id => @rreset.flickr_id)"
  end
  
  context 'Viewing the Rresets of a user with more than one (2) shared Rresets' do
    setup do
      expects_set_newest_flickr_photo_id do
        @rreset = Factory.create(:rreset)
      end
      
      @user = @rreset.user
      
      expects_set_newest_flickr_photo_id do
        Factory.create(:rreset, :user => @user)
      end
      
      assert_equal 2, @user.rresets.size
      
      get :index, :nsid => @user.flickr_nsid
    end
    
    should_render_template :index
    should_respond_with :success
    should_not_set_the_flash
    
    should "render all of the User's Rresets" do
      @user.rresets.each do |rreset|
        assert_select "#rreset_#{rreset.id}"
      end
    end
  end
  
  
private

  def setup_create_scenario
    @nsid = 'abc123'
    @photoset_id = "72157603698298686"
    @user = Factory.create(:user, :flickr_nsid => @nsid)
    login_as(@user)
    Flickr.expects(:photosets_get_info).with(@photoset_id).returns({
      "title" => "India", 
      "primary"=>"2187922813", 
      "farm"=>"3", "photos"=>"85", 
      "id"=> @photoset_id, 
      "description"=>nil, 
      "server"=>"2197", 
      "owner"=> @nsid, 
      "secret"=>"373d1b693c"
    }.symbolize_keys!)
    
    # The Rreset model calls this to determine the newest photo in the set
    # All we need to return is an array with one photo in it
    Flickr.expects(:photosets_get_photos).with(@photoset_id).returns([{:id => '2620994337'}])
  end
  
  def setup_destroy_scenario
    @user = Factory.create(:user)
    login_as(@user)
    expects_set_newest_flickr_photo_id do
      @rreset = Factory.create(:rreset, :user => @user)
    end
    @count = Rreset.count
  end
  
  def expects_set_newest_flickr_photo_id
    Flickr.expects(:photosets_get_photos).returns([{:id => '2620994337'}])
    yield
  end
  
end
