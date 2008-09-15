module HeaderTagHelper
  def title(title)
    content_for(:title) { title }
  end
  
  def javascript(*files)
    content_for(:header) { javascript_include_tag(*files) }
  end
  
  def stylesheet(*files)
    content_for(:header) { stylesheet_link_tag(*files) }
  end
end