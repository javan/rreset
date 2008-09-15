Factory.sequence :nsid do |n|
  "51035706609@N0#{n}"
end

Factory.sequence :username do |n|
  "javan#{n}"
end

Factory.define :user do |u|
  u.flickr_nsid      { Factory.next :nsid }
  u.flickr_username  { Factory.next :username }
  u.flickr_fullname  "Javan Makhmali"
end

Factory.define :rreset do |r|
  r.user { Factory.create(:user) }
  r.flickr_owner { |o| o.user.flickr_nsid } # An accessor used to validate ownership of the set
  r.flickr_farm "3"  
  r.flickr_photos 85
  r.flickr_primary "2187922813"
  r.flickr_title "India"
  r.flickr_description "From my trip to India"
  r.flickr_server "2197"
  r.flickr_secret "373d1b693c"
  r.flickr_id "72157603698298686"         
  r.newest_flickr_photo_id "2620994337"
end