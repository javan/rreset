ActionController::Routing::Routes.draw do |map|
  
  map.resource  :session
  map.resources :users
  map.resources :photos
  map.resources :pages
  map.resources :settings
  map.resource  :customizations
  map.resources :rresets
  
  map.root      :controller => 'pages'
  map.login     '/login', :controller => 'sessions', :action => 'new'
  map.logout    '/logout', :controller => 'sessions', :action => 'destroy'
  map.customize '/customize', :controller => 'customizations', :action => 'new'
  map.person    'people/:nsid', :controller => 'rresets'
  
  map.photo         ':set_id/:id', :controller => 'photos', :action => 'show'
  # Using set instead of rreset, because rreset is a resource defined above
  map.formatted_set ':set_id.:format', :controller => 'rresets', :action => 'show' # For the atom feed
  map.set           ':set_id', :controller => 'photos', :action => 'show' # Should come at the end
 
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
