class SettingsController < ApplicationController
  
  before_filter :login_required
  
  def index
    @rresets   = current_user.rresets.all.index_by(&:flickr_id)
    @photosets = Flickr.photosets_get_list(current_user.flickr_nsid)
  end
end
