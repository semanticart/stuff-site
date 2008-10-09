module RedClothExtensions
  HIGHLIGHT_SINGLE_LINE = '<code class="inline_code">%s</code>'
  HIGHLIGHT_MULTI_LINE = '<pre><code class="multiline_code">%s</code></pre>'
  HIGHLIGHT_WRAPPER = '<notextile>%s</notextile>'
  SOURCE_TAG_REGEXP = /((:?\t\n)?<source(?:\:([a-z]+))?>(.+?)<\/source>(?:\t\n)?)/m
  
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
  
  METADATA_REGEXP = /%%([a-z]+) (.+)\s/
end

RedCloth.class_eval do 
  include RedClothExtensions
end

class String
  def has_newlines?
    self =~ /\n/
  end
end

class Thingie
  attr_reader :title, :permalink, :textilized, :created_at, :topic
  METADATA_REGEXP = /^%%([a-z]+) (.+)\s/

  def initialize(path)
    filename = File.basename(path)
    
    @permalink = filename[0..-9]
    @text = File.read(path)
    extract_metadata_from_text
    
    @created_at = get_created_at
    @topic = (@metadata['topic'] || 'stuff').capitalize
    
    @textilized = RedCloth.new(@text).to_html(:textile, :refs_syntax_highlighter)
    @title = @permalink.split('_').map {|c| c.capitalize }.join(' ')
  end
  
  private
  
  def extract_metadata_from_text
    @metadata = {}
    @text.gsub!(METADATA_REGEXP) do |m|
      @metadata[$~[1]] = $~[2]
      nil
    end
  end
  
  def get_created_at
    Time.utc(*@metadata['created'].split(' '))
  end
end