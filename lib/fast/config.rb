module Fast
  class Config 
    DEFAULT_CONFIG_PATH = File.expand_path('~/.fast_config')
    
    class << self
      attr_reader :commands
    end    
    
    @commands = {}
    @config = {}
    
    def self.register_command(command)
      if @commands.has_key?(command.usage)
        raise FastError, "Duplicate command `#{command.usage}'"
      end
      @commands[command.usage] = command
    end
    
    def self.init(file_path = DEFAULT_CONFIG_PATH)
      @config = File.exist?(file_path)? YAML.load_file(file_path) : {}
    end
    
    def self.[](k)
      @config[k]
    end
    
    def self.github
      @config["github"] || {}
    end
  end
end
