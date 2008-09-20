class PhotosController < ApplicationController
  
  def show
    @rreset  = Rreset.find_by_flickr_id_and_sync!(params[:set_id], :include => :user)
    @user    = @rreset.user
    
    # If no photo id is provided, show the newest photo in the set
    if params[:id].nil? 
      params[:id] = @rreset.newest_flickr_photo_id
      @first_photo = true
    end
    load_context
    
    # If we're on the newest photo, but the context tells us there's a next photo,
    # the rreset is out of sync with flickr so update it
    if @context[:nextphoto] && @first_photo
      @rreset.sync_with_flickr!
      params[:id] = @rreset.newest_flickr_photo_id
      load_context
    end
    
    @photo   = Flickr.photos_get_info(params[:id])
    @sizes   = Flickr.photos_get_sizes(params[:id])
    @license = Flickr.photos_licenses_get_info(@photo[:license])
  end
  
private
  
  def load_context
    @context = Flickr.photosets_get_context(params[:id], params[:set_id])
  end
  
end
