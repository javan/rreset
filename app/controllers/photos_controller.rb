class PhotosController < ApplicationController
  
  def show
    @rreset = Rreset.find_with_update_by_flickr_id!(params[:set_id], :include => :user)
    @user   = @rreset.user
    
    # If no photo id is provided, show the newest photo in the set
    params[:id] ||= @rreset.newest_flickr_photo_id
    
    @context = Flickr.photosets_get_context(params[:id], params[:set_id])
    @photo   = Flickr.photos_get_info(params[:id])
    @sizes   = Flickr.photos_get_sizes(params[:id])
    @license = Flickr.photos_licenses_get_info(@photo[:license])
  end
  
end
