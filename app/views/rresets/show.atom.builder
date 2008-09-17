atom_feed do |feed|
  feed.title("#{@rreset.flickr_title} - on Rreset")
  feed.updated(@rreset.updated_at)

  for photo in @photos
    url = photo_url(:set_id => @rreset.flickr_id, :id => photo[:id], :from => 'feed')
    feed.entry(photo, :url => url, :id => "flickr:#{photo[:id]}") do |entry|
      entry.title(photo_title(photo))
      entry.content(link_to(photo_thumbnail(photo), url), :type => 'html')
      entry.author do |author|
        author.name(@rreset.user.display_name)
      end
    end
  end
end