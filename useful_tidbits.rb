class String
  def has_newlines?
    self =~ /\n/
  end
end

class Hash
  # Turns {:src => "foo.jpg", :alt => "Oh hai"} into 'src="foo.jpg" alt="Oh hai"'.
  def to_html_tag_attributes
    map {|k, v| "#{k}=\"#{v}\""}.join(" ")
  end
end

module RedClothExtensions
  HIGHLIGHT_SINGLE_LINE = '<code class="inline_code">%s</code>'
  HIGHLIGHT_MULTI_LINE = '<pre><code class="multiline_code">%s</code></pre>'
  HIGHLIGHT_WRAPPER = '<notextile>%s</notextile>'
  SOURCE_TAG_REGEXP = /((:?\t\n)?<source(?:\:([a-z]+))?>(.+?)<\/source>(?:\t\n)?)/m
  
  # Scans for <source></source> tags and syntax highligts them. The output is either
  # one of HIGHLIGHT_SINGLE_LINE og HIGHLIGHT_MULTI_LINE, with the CodeRay syntax
  # highlighted output where the %s is.
  def refs_syntax_highlighter(text)
    text.gsub!(SOURCE_TAG_REGEXP) do |m|
      all_of_it = $~[1]
      lang = ($~[3] || :ruby).to_sym
      code = $~[4].strip
      
      wrap_in = all_of_it.has_newlines? ? HIGHLIGHT_MULTI_LINE : HIGHLIGHT_SINGLE_LINE
      highlighted = wrap_in % CodeRay.scan(code, lang).div(:wrap => nil, :css => :class)
      HIGHLIGHT_WRAPPER % highlighted
    end
  end  
end

RedCloth.class_eval do 
  include RedClothExtensions
end

# The actual, uhm, articles.
class Thingie
  attr_reader :title, :permalink, :textilized, :created_at, :topic
  METADATA_REGEXP = /^%%([a-z]+) (.+)\s/
  IMAGE_REGEXP = /^img\. ([\w.]+)(?: (.+))?/

  def initialize(path)
    filename = File.basename(path)
    
    @permalink = filename[0..-9]
    @text = File.read(path)
    extract_metadata_from_text
    parse_images
    
    @created_at = get_created_at
    @topic = (@metadata['topic'] || 'stuff')
    
    @textilized = RedCloth.new(@text).to_html(:textile, :refs_syntax_highlighter)
    @title = @permalink.split('_').map {|c| c.capitalize }.join(' ')
  end
  
  private
  
  # Extracts metadata, such as '%%topic foo', out of the texts.
  def extract_metadata_from_text
    @metadata = {}
    @text.gsub!(METADATA_REGEXP) do |m|
      @metadata[$~[1]] = $~[2]
      nil
    end
  end
  
  # Instead of using RedCloths !image-url.here! syntax, this looks for
  # 'img. foo.jpg' and handles a dynamic absolute URL automagically.
  def parse_images
    @text.gsub!(IMAGE_REGEXP) do |m|
      filename = $~[1]
      alt_text = $~[2]
      
      options = {}
      options[:src] = "http://#{CONFIG['url']}/images/#{permalink}/#{filename}"
      if alt_text
        options[:alt] = alt_text
        options[:title] = alt_text
      end
      
      "<img #{options.to_html_tag_attributes} />"
    end
  end
  
  def get_created_at
    Time.utc(*@metadata['created'].split(' '))
  end
end

thingie_paths = Dir.glob(File.join(File.dirname(__FILE__), 'thingies', '*.textile'))
ALL_THINGIES = thingie_paths.map {|path| Thingie.new(path) }.sort_by {|l| l.created_at }.reverse