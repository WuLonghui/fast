module Fast
  module Command
    class Help < Base
      usage "help"
      desc "Show help message"
      def help(*keywords)
        if runner.nil?
          err("Cannot show help message, command runner is not instantiated")
        end
      
        keyword_help(keywords)
      end
      
      private
      
      def generic_help
        message = <<-HELP.gsub(/^\s*\|/, "")
          |Fast is a DevOps tool.
          |
          |#{runner.usage}
          |
        HELP
      
        say message
      end
      
      def keyword_help(keywords)
        matches = Fast::Config.commands.values
        
        if keywords.empty?
          generic_help
          good_matches = matches.sort { |a, b| a.usage <=> b.usage }
        else
          good_matches = []
          matches.each do |command|
            common_keywords = command.keywords & keywords
            if common_keywords.size > 0
              good_matches << command
            end
          
            good_matches.sort! do |a, b|
              cmp = (b.keywords & keywords).size <=> (a.keywords & keywords).size
              cmp = (a.usage <=> b.usage) if cmp == 0
              cmp
            end
          end
        end
        
        self.class.list_commands(good_matches)
      end
      
      def self.list_commands(commands)
        help_column_width = terminal_width - 5
        help_indent = 4
        
        commands.each_with_index do |command, i|
          nl if i > 0
          say("#{command.usage_with_params.columnize(210).make_green}")
          say(command.desc.columnize(help_column_width).indent(help_indent))
          if command.has_options?
            say(command.options_summary.indent(help_indent))
          end
        end
      end
    end
  end
end
