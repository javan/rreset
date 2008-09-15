module FlashMessagesHelper
  def flash_messages
    html = []
    [:error, :warning, :notice, :message].each do |key|
      html << content_tag(:div, flash[key], :id => "flash_#{key}", :class => 'flash_message') if flash[key]
    end
    html.join("\n")
  end
end