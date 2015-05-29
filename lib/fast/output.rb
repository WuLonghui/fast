module Fast
  class Output
    class << self
      attr_accessor :debug
      attr_accessor :colorize
    end
    
    @debug = false
    @colorize = true
  end

  class LineWrap
    def initialize(width, left_margin = 0)
      @width = width
      @left_margin = left_margin
    end

    def wrap(string)
      paragraphs = string.split("\n")

      wrapped_paragraphs = paragraphs.map do |paragraph|
        lines = wrapped_lines(paragraph)
        lines = indent_lines(lines)

        paragraph_indentation(paragraph) + lines.join("\n")
      end

      wrapped_paragraphs.join("\n")
    end

    private

    attr_reader :width
    attr_reader :left_margin

    def paragraph_indentation(paragraph)
      paragraph.start_with?('      ') ? '  ' : ''
    end

    def wrapped_lines(string)
      result = []
      buffer = ''

      string.split(' ').each do |word|
        if new_line_needed?(buffer, word)
          result << buffer
          buffer = word
        else
          buffer << ' ' unless buffer.empty?
          buffer << word
        end
      end
      result << buffer
    end

    def new_line_needed?(buffer, word)
      buffer.size + word.size > width
    end

    def indent_lines(lines)
      lines.map { |line| (' ' * left_margin) + line }
    end
  end
end

module OutputExtensions
  def say(message, sep = "\n")
    message = message.dup.to_s
    sep = "" if message[-1..-1] == sep
    STDOUT.print("#{$indent}#{message}#{sep}")
    STDOUT.flush
  end
  
  def with_indent(indent)
    old_indent, $indent = $indent, old_indent.to_s + indent.to_s
    yield
  ensure
    $indent = old_indent
  end
  
  def print_json(json)
   say JSON.pretty_generate(json || {})
  end
  
  def print_backtrace(err)
    return unless Fast::Output.debug
    print_header "Backtrace:" 
    print_json err.backtrace
    nl
  end

  def print_header(message, filler = '-')
    say("\n")
    say(message)
    say(filler.to_s * message.size)
  end
  
  def say_debug(message)
    say("[DEBUG] #{message}".make_green) if Fast::Output.debug
  end
  
  def say_warning(message)
    warn("[WARNING] #{message}".make_yellow)
  end
  
  def say_error(message, sep = "\n")
    message = message.dup.to_s
    message = message.dup.to_s
    sep = "" if message[-1..-1] == sep
    STDERR.print("[ERROR] #{$indent}#{message.make_red}#{sep}")
  end
  
  def nl(count = 1)
    say("\n" * count)
  end

  def format_time(time)
    ts = time.to_i
    sprintf("%02d:%02d:%02d", ts / 3600, (ts / 60) % 60, ts % 60);
  end
  
  def terminal_width
    STDIN.tty? ? [HighLine::SystemExtensions.terminal_size[0], 120].min : 80
  end
  
end


module StringExtensions

  COLOR_CODES = {
    :red => "\e[0m\e[31m",
    :green => "\e[0m\e[32m",
    :yellow => "\e[0m\e[33m"
  }

  def make_red
    make_color(:red)
  end

  def make_green
    make_color(:green)
  end

  def make_yellow
    make_color(:yellow)
  end

  def make_color(color_code)
    if Fast::Output.colorize 
       COLOR_CODES[color_code]
      "#{COLOR_CODES[color_code]}#{self}\e[0m"
    else
      self
    end
  end

  def blank?
    self =~ /^\s*$/
  end

  def truncate(limit = 30)
    return "" if self.blank?
    etc = "..."
    stripped = self.strip[0..limit]
    if stripped.length > limit
      stripped.gsub(/\s+?(\S+)?$/, "") + etc
    else
      stripped
    end
  end

  def columnize(width = 80, left_margin = 0)
    Fast::LineWrap.new(width, left_margin).wrap(self)
  end

  def indent(margin = 2)
    self.split("\n").map { |line|
      " " * margin + line
    }.join("\n")
  end

end

class Object
  include OutputExtensions
end

class String
  include StringExtensions
end