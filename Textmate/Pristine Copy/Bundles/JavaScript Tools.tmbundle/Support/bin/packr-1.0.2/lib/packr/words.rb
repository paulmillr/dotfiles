class Packr
  class Words
    
    WORDS = /\w+/
    attr_accessor :words
    
    def initialize(script)
      script.to_s.scan(WORDS).each { |word| add(word) }
      encode!
    end
    
    def add(word)
      @words ||= []
      @words << (stored_word = Item.new(word)) unless stored_word = get(word)
      word = stored_word
      word.count = word.count + 1
      word
    end
    
    def get(word)
      @words.find { |w| w.word == word.to_s }
    end
    
    def has?(word)
      !!(get word)
    end
    
    def size
      @words.size
    end
    
    def to_s
      @words.join("|")
    end
    
  private
    
    def encode!
      # sort by frequency
      @words = @words.sort_by { |word| word.count }.reverse
      
      a = 62
      e = lambda do |c|
        (c < a ? '' : e.call((c.to_f / a).to_i) ) +
            ((c = c % a) > 35 ? (c+29).chr : c.to_s(36))
      end
      
      # a dictionary of base62 -> base10
      encoded = (0...(@words.size)).map { |i| e.call(i) }
      
      index = 0
      @words.each do |word|
        if x = encoded.index(word.word)
          word.index = x
          def word.to_s; ""; end
        else
          index += 1 while has?(e.call(index))
          word.index = index
          index += 1
        end
        word.encoded = e.call(word.index)
      end
      
      # sort by encoding
      @words = @words.sort_by { |word| word.index }
    end
    
    class Item
      attr_accessor :word, :count, :encoded, :index
      
      def initialize(word)
        @word = word
        @count = 0
        @encoded = ""
        @index = -1
      end
      
      def to_s
        @word
      end
    end
    
  end
end
