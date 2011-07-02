module RBeautify

  class Line

    # indent_character
    @@indent_character = " "

    attr_reader :language, :content, :line_number, :original_block, :block

    def initialize(language, content, line_number, original_block = nil)
      @language = language
      @content = content
      @original_block = original_block
      @block = BlockMatcher.parse(language, original_block, line_number, stripped, 0)
    end

    def format
      if @formatted.nil?
        if format?
          if stripped.length == 0
            @formatted = ""
          else
            @formatted = tab_string + stripped
          end
        else
          @formatted = content
        end
      end

      @formatted
    end

    private
      def format?
        original_block.nil? || original_block.format_content?
      end

      def indent_size
        if (block.nil? || block.strict_ancestor_of?(original_block)) && (original_block && original_block.indent_end_line?)
          original_block.total_indent_size
        else
          common_ancestor = BlockStart.first_common_ancestor(original_block, block)
          common_ancestor.nil? ? 0 : common_ancestor.total_indent_size
        end
      end

      def tab_string
        @@indent_character * indent_size
      end

      def stripped
        @stripped = content.strip
      end

  end

end
