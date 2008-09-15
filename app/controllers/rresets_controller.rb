class RresetsController < ApplicationController
  
  before_filter :login_required, :except => :index
  
  def index
    @user = User.find_by_flickr_nsid(params[:nsid], :include => :rresets)
    raise ActiveRecord::RecordNotFound if @user.nil?
  end
  
  def create
    @photoset = Flickr.photosets_get_info(params[:photoset_id])
    @rreset = current_user.rresets.find_or_initialize_by_flickr_id(@photoset.prefix_keys_with('flickr_'))
    
    @saved = @rreset.save
    respond_to do |format|
      format.html do
        if @saved
          flash[:notice] = 'Photoset is now displayed. Yay!'
        else
          flash[:error] = 'Something went wrong. Please try again.'
        end
        redirect_to settings_path
      end
      format.js
    end
  end
  
  def destroy
    @rreset = current_user.rresets.find(params[:id])
    
    @destroyed = @rreset.destroy
    respond_to do |format|
      format.html do
        if @destroyed
          flash[:notice] = 'Photoset is no longer displayed.'
        else
          flash[:error] = 'Something went wrong. Please try again.'
        end
        redirect_to settings_path
      end
      format.js
    end
    
  end
end
