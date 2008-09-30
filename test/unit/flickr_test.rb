require 'test_helper'

class FlickrTest < ActiveSupport::TestCase
  context 'A flickr instance in general' do
    setup do
      @flickr = Flickr.new
    end
    
    should_have_instance_methods :params, :signed_request, :params=, :signed_request=, :method, :method=, :cache_key, :cache_key=
    
    context 'when building the url it' do
      should 'contain the api key' do
        assert @flickr.send(:build_url) =~ /api_key=.*/
      end
      
      should 'contain the api sig if the request is to signed' do
        @flickr.signed_request = true
        assert @flickr.send(:build_url) =~ /api_sig=.*/
      end
      
      should 'contain the auth url in the url with a type of :auth' do
        assert Flickr.new(:type => :auth).send(:build_url) =~ /^#{Flickr::AUTH_ENDPOINT}\?/
      end
    
      should 'contain the api url in the url with a type of :api' do
        assert Flickr.new(:type => :api).send(:build_url) =~ /^#{Flickr::API_ENDPOINT}\?/
      end
    end
    
    should 'raise an exception if a failing response is received from flickr' do
      mock_flickr_call('flickr_failed_response')
      @flickr.method = :whatever
      assert_raises Flickr::ConnectionError do
        @flickr.send(:invoke!)
      end
    end
    
    should 'raise an exception if nothing is returned from flickr' do
      mock_flickr_call('flickr_empty_response')
      @flickr.method = :whatever
      assert_raises Flickr::ConnectionError do
        @flickr.send(:invoke!)
      end
    end
    
    should 'raise an exception if the response from flickr is not sucessful' do
      assert_raises Flickr::ConnectionError do
        @flickr.send(:handle_response, Net::HTTPClientError.new('1.2', '404', 'BAD'))
      end
    end
    
    should 'not raise anything if the response from flickr is successful' do
      assert_nothing_raised do
        response = Net::HTTPSuccess.new('1.2', '200', 'OK')
        response.stubs(:closed?).returns(true)
        response.stubs(:body).returns('hello from flickr')
        @flickr.send(:handle_response, response)
      end
    end
  end
  
  context 'Flickr.auth_get_token' do
    should 'return a response with all the data we want' do
      mock_flickr_call('flickr_auth_get_token')
      @token = Flickr.auth_get_token('frob')
      assert_instance_of Hash, @token
      assert @token.keys.include?(:auth)
    end
  end
  
  context 'Flickr.photosets_get_list' do
    should 'return a response with all the data we want' do
      mock_flickr_call('flickr_photosets_get_list')
      @list = Flickr.photosets_get_list('nsid')
      assert_instance_of Array, @list
      assert_equal 31, @list.size
    end
    
    should 'return an array of photosets even if there is only one set' do
      mock_flickr_call('flickr_photosets_get_list_one_set')
      @list = Flickr.photosets_get_list('nsid')
      assert_instance_of Array, @list
      assert_equal 1, @list.size
    end
    
    should 'return an empty array of photosets if there are no sets' do
      mock_flickr_call('flickr_photosets_get_list_no_sets')
      @list = Flickr.photosets_get_list('nsid')
      assert_instance_of Array, @list
      assert_equal 0, @list.size
    end
  end
  
  context 'Flickr.photosets_get_info' do
    should 'return a response with all the data we want' do
      mock_flickr_call('flickr_photosets_get_info')
      @photoset = Flickr.photosets_get_info('photosetid')
      assert_instance_of Hash, @photoset
      assert @photoset.keys.include?(:title)
    end
  end
  
  context 'Flickr.photosets_get_photos' do
    should 'should make three calls to flickr if there are more than 1000 photos in a set (1 call per 500)' do
      # We're faking (mocking) 1001 as the total, but really there's only 60 in the xml file for testing.
      Flickr.expects(:photosets_get_info).with(anything).returns({ :photos => 1001 })
      mock_flickr_call('flickr_photosets_get_photos', 3)
      @photos = Flickr.photosets_get_photos('photosetid')
      assert_instance_of Array, @photos
      # Since the API should have been hit three times, there should be triple the count (60) of photos
      assert_equal 180, @photos.size
    end
    
    should 'should make one call to flickr if there are less than 500 photos in the set' do
      # We're faking (mocking) 22 as the total, but really there's only 60 in the xml file for testing.
      Flickr.expects(:photosets_get_info).with(anything).returns({ :photos => 22 })
      mock_flickr_call('flickr_photosets_get_photos', 1)
      @photos = Flickr.photosets_get_photos('photosetid')
      assert_instance_of Array, @photos
      assert_equal 60, @photos.size
    end
  end
  
  context 'Flickr.photosets_get_context' do
    should 'return next and prev photo for a normal request' do
      mock_flickr_call('flickr_photosets_get_context')
      @context = Flickr.photosets_get_context('photoid', 'photosetid')
      assert_instance_of Hash, @context
      assert @context.keys.include?(:nextphoto)
      assert @context.keys.include?(:prevphoto)
    end
    
    should 'not return a prev photo if first photo in set' do
      mock_flickr_call('flickr_photosets_get_context_first_in_set')
      @context = Flickr.photosets_get_context('photoid', 'photosetid')
      assert @context.keys.include?(:nextphoto)
      assert !@context.keys.include?(:prevphoto)
    end
    
    should 'not return a next photo if last photo in set' do
      mock_flickr_call('flickr_photosets_get_context_last_in_set')
      @context = Flickr.photosets_get_context('photoid', 'photosetid')
      assert @context.keys.include?(:prevphoto)
      assert !@context.keys.include?(:nextphoto)
    end
    
    should 'raise an exception if the photo is not in the set' do
      mock_flickr_call('flickr_photosets_get_context_fail_not_in_set')
      assert_raises Flickr::ConnectionError do
        Flickr.photosets_get_context('photoid', 'photosetid')
      end
    end
  end
  
  context 'Flickr.photos_get_info' do
    should 'return a response with all the data we want' do
      mock_flickr_call('flickr_photos_get_info')
      @photo = Flickr.photos_get_info('photo_id')
      assert_instance_of Hash, @photo
      assert @photo.keys.include?(:title)
    end
  end
  
  context 'Flickr.photos_get_sizes' do
    should 'return a response with all the data we want' do
      mock_flickr_call('flickr_photos_get_sizes')
      @sizes = Flickr.photos_get_sizes('photo_id')
      assert_instance_of Hash, @sizes
      assert @sizes.keys.include?(:thumbnail)
    end
  end
  
  context 'A Flickr instance that caches' do
    setup do
      @cache_key = File.join('test', 'photosets', '1', 'info')
      mock_flickr_call('flickr_photos_get_info')
      ActionController::Base.expects(:cache_configured?).returns(true) # Make sure the caching happens
      
      @flickr = Flickr.new(
        :method => 'flickr.photos.getInfo',
        :params => { :photo_id => 1 },
        :cache_key => @cache_key
      ).send(:invoke!)
    end
    
    should 'create a cached file of the api response where we expect it to' do
      assert File.exists?(File.join(RAILS_ROOT, 'tmp', 'cache', "#{@cache_key}.cache"))
    end
    
    should 'cache a valid xml file' do
      xml = Hash.from_xml(File.read(File.join(RAILS_ROOT, 'tmp', 'cache', "#{@cache_key}.cache")))
      assert_instance_of Hash, xml
    end
    
    teardown do
      # Remove the cache files
      FileUtils.rm_r(File.join(RAILS_ROOT, 'tmp', 'cache', 'test'))
    end
  end
end
