# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # print javascript for each item in array of files in head section
  def javascript(*files)
    content_for(:javascripts) { javascript_include_tag(*files) }
  end

  # print stylesheet for each item in array of files in head section
  def stylesheet(*files)
    content_for(:stylesheets) { stylesheet_link_tag(*files) }
  end
  
  def favicon
    "<link rel=\"shortcut icon\" href=\"/images/favicon.png\" />"
  end

  def flash_notices
    [:notice, :error, :warning].collect do |type|
      content_tag('div', flash[type], :class=>"message #{type}", :id => "flash_messages") if flash[type]
    end
  end
end
