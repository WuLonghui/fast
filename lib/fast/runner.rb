module Fast
  class Runner
    def initialize(args)
      @args = args
      @options = {}
      @options["debug"] = false      
            
      Fast::Output.colorize = true
    end
    
    def parse_global_options
      opts = OptionParser.new
      opts.banner = "Usage: fast [<options>] <command> [<args>]"
      opts.on_tail("-v", "--version", "Show version") do
        say Fast::VERSION
        exit 0
      end

      opts.on("--[no-]color", "Toggle colorized output") do |v|
        Fast::Output.colorize = v
      end
            
      opts.on("-d", "--debug", "Run with debug") do |v| 
        @options["debug"] = true; 
        Fast::Output.debug = true 
      end
      
      opts.on("-h", "--help", "here you go") do
        @args << 'help'
      end
      
      @option_parser = opts
      @args = @option_parser.order!(@args)
    end
    
    def usage
      @option_parser.to_s
    end
            
    def build_parse_tree
      @parse_tree = ParseTreeNode.new

      Config.commands.each_value do |command|
        p = @parse_tree
        n_kw = command.keywords.size

        command.keywords.each_with_index do |kw, i|
          p[kw] ||= ParseTreeNode.new
          p = p[kw]
          p.command = command if i == n_kw - 1
        end
      end
    end
    
    def search_parse_tree(node)
      return nil if node.nil?
      arg = @args.shift

      longer_command = search_parse_tree(node[arg])

      if longer_command.nil?
        @args.unshift(arg) if arg # backtrack if needed
        node.command
      else
        longer_command
      end
    end
    
    def run
      parse_global_options
      build_parse_tree
      
      Config.init  
      
      @args = %w(help) if @args.empty?
      command = search_parse_tree(@parse_tree)
      
      if command.nil?
        raise UnknownCommand, "Unknown command: #{@args.join(" ")}"
      end

      command.runner = self
      
      begin
      exit_code = command.run(@args, @options)
      exit(exit_code)
      rescue OptionParser::ParseError => err
        say_error(err.message)
        nl
        say("Usage: fast #{command.usage_with_params.columnize(210)}")
        if command.has_options?
          say(command.options_summary.indent(7))
        end
        exit 1
      end
    rescue OptionParser::ParseError => err
      say_error(err.message)
      nl
      say(@option_parser.to_s)
      exit 1
    rescue Fast::FastError=> err
      say_error "#{err.to_s}"
      print_backtrace err
      exit err.exit_code
    end
     
     
    class ParseTreeNode < Hash
      attr_accessor :command
    end
  end
end
