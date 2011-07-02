# PackR -- a Ruby port of Packer by Dean Edwards
# Packer version 3.0 (final) - copyright 2004-2007, Dean Edwards
# http://www.opensource.org/licenses/mit-license

require "#{ENV['TM_BUNDLE_SUPPORT']}/bin/packr-1.0.2/lib/string.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/bin/packr-1.0.2/lib/packr/regexp_group.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/bin/packr-1.0.2/lib/packr/words.rb"

class Packr
  
  PROTECTED_NAMES = %w($super)
  
  class << self
    def protect_vars(*args)
      @packr ||= self.new
      @packr.protect_vars(*args)
    end
    
    def minify(script)
      @packr ||= self.new
      @packr.minify(script)
    end
    
    def pack(script, options = {})
      @packr ||= self.new
      @packr.pack(script, options)
    end
    
    def pack_file(path, options = {})
      @packr ||= self.new
      @packr.pack_file(path, options)
    end
  end
  
  IGNORE = RegexpGroup::IGNORE
  REMOVE = ""
  SPACE = " "
  WORDS = /\w+/
  
  CONTINUE = /\\\r?\n/
  
  ENCODE10 = "String"
  ENCODE36 = "function(c){return c.toString(a)}"
  ENCODE62 = "function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))}"
  
  UNPACK = lambda do |p,a,c,k,e,r|
    "eval(function(p,a,c,k,e,r){e=#{e};if(!''.replace(/^/,String)){while(c--)r[#{r}]=k[c]" +
        "||#{r};k=[function(e){return r[e]}];e=function(){return'\\\\w+'};c=1};while(c--)if(k[c])p=p." +
        "replace(new RegExp('\\\\b'+e(c)+'\\\\b','g'),k[c]);return p}('#{p}',#{a},#{c},'#{k}'.split('|'),0,{}))"
  end
  
  CLEAN = RegexpGroup.new(
    "\\(\\s*;\\s*;\\s*\\)" => "(;;)", # for (;;) loops
    "throw[^};]+[};]" => IGNORE, # a safari 1.3 bug
    ";+\\s*([};])" => "\\1"
  )
  
  DATA = RegexpGroup.new(
    # strings
    "STRING1" => IGNORE,
    'STRING2' => IGNORE,
    "CONDITIONAL" => IGNORE, # conditional comments
    "(COMMENT1)\\n\\s*(REGEXP)?" => "\n\\3",
    "(COMMENT2)\\s*(REGEXP)?" => " \\3",
    "([\\[(\\^=,{}:;&|!*?])\\s*(REGEXP)" => "\\1\\2"
  )
  
  JAVASCRIPT = RegexpGroup.new(
    :COMMENT1 =>    /(\/\/|;;;)[^\n]*/.source,
    :COMMENT2 =>    /\/\*[^*]*\*+([^\/][^*]*\*+)*\//.source,
    :CONDITIONAL => /\/\*@|@\*\/|\/\/@[^\n]*\n/.source,
    :REGEXP =>      /\/(\\[\/\\]|[^*\/])(\\.|[^\/\n\\])*\/[gim]*/.source,
    :STRING1 =>     /'(\\.|[^'\\])*'/.source,
    :STRING2 =>     /"(\\.|[^"\\])*"/.source
  )
  
  WHITESPACE = RegexpGroup.new(
    "(\\d)\\s+(\\.\\s*[a-z\\$_\\[(])" => "\\1 \\2", # http://dean.edwards.name/weblog/2007/04/packer3/#comment84066
    "([+-])\\s+([+-])" => "\\1 \\2", # c = a++ +b;
    "\\b\\s+\\$\\s+\\b" => " $ ", # var $ in
    "\\$\\s+\\b" => "$ ", # object$ in
    "\\b\\s+\\$" => " $", # return $object
    "\\b\\s+\\b" => SPACE,
    "\\s+" => REMOVE
  )
  
  def initialize
    @data = {}
    DATA.values.each { |item| @data[JAVASCRIPT.exec(item.expression)] = item.replacement }
    @data = RegexpGroup.new(@data)
    @whitespace = @data.union(WHITESPACE)
    @clean = @data.union(CLEAN)
    @protected_names = PROTECTED_NAMES
  end
  
  def protect_vars(*args)
    args = args.map { |arg| arg.to_s.strip }.select { |arg| arg =~ /^[a-z\_\$][a-z0-9\_\$]*$/i }
    @protected_names = (@protected_names + args).uniq
  end
  
  def minify(script)
    script = script.gsub(CONTINUE, "")
    script = @data.exec(script)
    script = @whitespace.exec(script)
    script = @clean.exec(script)
    script
  end
  
  def pack(script, options = {})
    script = minify(script + "\n")
    script = shrink_variables(script) if options[:shrink_vars]
    script = base62_encode(script) if options[:base62]
    script
  end
  
  def pack_file(path, options = {})
    path = path.gsub("#{ENV['TM_DIRECTORY']}", '/')
    script = File.read(path)
    script = pack(script, options)
    File.open(path, 'wb') { |f| f.write(script) }
  end
  
private
  
  def base62_encode(script)
    words = Words.new(script)
    encode = lambda { |word| words.get(word).encoded }
    
    # build the packed script
    
    p = escape(script.gsub(Words::WORDS, &encode))
    a = [[words.size, 2].max, 62].min
    c = words.size
    k = words.to_s
    e = self.class.const_get("ENCODE#{a > 10 ? (a > 36 ? 62 : 36) : 10}")
    r = a > 10 ? "e(c)" : "c"
    
    # the whole thing
    UNPACK.call(p,a,c,k,e,r)
  end
  
  def escape(script)
    # single quotes wrap the final string so escape them
    # also escape new lines required by conditional comments
    script.gsub(/([\\'])/) { |match| "\\#{$1}" }.gsub(/[\r\n]+/, "\\n")
  end
  
  def shrink_variables(script)
    data = [] # encoded strings and regular expressions
    regexp= /^[^'"]\//
    store = lambda do |string|
      replacement = "##{data.length}"
      if string =~ regexp
        replacement = string[0].chr + replacement
        string = string[1..-1]
      end
      data << string
      replacement
    end
    
    # Base52 encoding (a-Z)
    encode52 = lambda do |c|
      (c < 52 ? '' : encode52.call((c.to_f / 52).to_i) ) +
          ((c = c % 52) > 25 ? (c + 39).chr : (c + 97).chr)
    end
    
    # identify blocks, particularly identify function blocks (which define scope)
    __block = /(function\s*[\w$]*\s*\(\s*([^\)]*)\s*\)\s*)?(\{([^{}]*)\})/
    __var = /var\s+/
    __var_name = /var\s+[\w$]+/
    __comma = /\s*,\s*/
    blocks = [] # store program blocks (anything between braces {})
    
    # decoder for program blocks
    encoded = /~(\d+)~/
    decode = lambda do |script|
      script = script.gsub(encoded) { |match| blocks[$1.to_i] } while script =~ encoded
      script
    end
    
    # encoder for program blocks
    encode = lambda do |match|
      block, func, args = match, $1, $2
      if func # the block is a function block
        
        # decode the function block (THIS IS THE IMPORTANT BIT)
        # We are retrieving all sub-blocks and will re-parse them in light
        # of newly shrunk variables
        block = decode.call(block)
        
        # create the list of variable and argument names
        vars = block.scan(__var_name).join(",").gsub(__var, "")
        ids = (args.split(__comma) + vars.split(__comma)).uniq
        
        #process each identifier
        count = 0
        ids.each do |id|
          id = id.strip
          if id and id.length > 1 and !@protected_names.include?(id) # > 1 char
            id = id.rescape
            # find the next free short name (check everything in the current scope)
            short_id = encode52.call(count)
            while block =~ Regexp.new("[^\\w$.]#{short_id}[^\\w$:]")
              count += 1
              short_id = encode52.call(count)
            end
            # replace the long name with the short name
            reg = Regexp.new("([^\\w$.])#{id}([^\\w$:])")
            block = block.gsub(reg, "\\1#{short_id}\\2") while block =~ reg
            reg = Regexp.new("([^{,\\w$.])#{id}:")
            block = block.gsub(reg, "\\1#{short_id}:")
          end
        end
      end
      replacement = "~#{blocks.length}~"
      blocks << block
      replacement
    end
    
    # encode strings and regular expressions
    script = @data.exec(script, &store)
    
    # remove closures (this is for base2 namespaces only)
    script = script.gsub(/new function\(_\)\s*\{/, "{;#;")
    
    # encode blocks, as we encode we replace variable and argument names
    script = script.gsub(__block, &encode) while script =~ __block
    
    # put the blocks back
    script = decode.call(script)
    
    # put back the closure (for base2 namespaces only)
    script = script.gsub(/\{;#;/, "new function(_){")
    
    # put strings and regular expressions back
    script = script.gsub(/#(\d+)/) { |match| data[$1.to_i] }
    
    script
  end
end
