module ApplicationHelper
  def javascript(*files)
    content_for(:javascripts) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:stylesheets) { stylesheet_link_tag(*files) }
  end

  def favicon
    "<link rel=\"shortcut icon\" href=\"/images/favicon.png\" />"
  end

  def flash_notices
    flash.collect do |key, value|
      content_tag('div', value, :class=>"message #{key}", :id => "flash_messages")
    end
  end
  
  def analytics(site_id)
    <<-ANALYTICS
    <script>
     var _gaq = [['_setAccount', '#{site_id}'], ['_trackPageview']];
     (function(d, t) {
      var g = d.createElement(t),
          s = d.getElementsByTagName(t)[0];
      g.async = true;
      g.src = '//www.google-analytics.com/ga.js';
      s.parentNode.insertBefore(g, s);
     })(document, 'script');
    </script>
    ANALYTICS
  end

end