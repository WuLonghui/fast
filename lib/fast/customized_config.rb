module Fast
  class CustomizedConfig
    CUSTOMIZED_CONFIG_FILE = ".fast.yml"
         
    def initialize(workspace, path, customized_config_file)
      @workspace = workspace
      @path = path
      @customized_config_file = customized_config_file || CUSTOMIZED_CONFIG_FILE
      
      customized_config_path = File.expand_path(File.join(@workspace.host_workspace, @path, @customized_config_file))
 
      raise FileNotFound, "#{customized_config_path} not found" unless File.exist?(customized_config_path)

      @config = YAML.load_file(customized_config_path) || {}
    end
    
    def get_task_configs
      task_config_options = {"path" => @path, "customized_config_file" => @customized_config_file}
      if @config.is_a?(Array) then
        return @config.map {|config| TaskConfig.new(config.merge(task_config_options)) }
      else
        return [TaskConfig.new(@config.merge(task_config_options))]
      end
    end    
    
    def parse
      task_configs = []
      (@config.delete("include") || []).each do |item|  
        if item.is_a?(Hash) then
          path = item["path"]
          customized_config = item["customized_config"] || CUSTOMIZED_CONFIG_FILE
        elsif item.is_a?(String) then
          path = item
          customized_config = CUSTOMIZED_CONFIG_FILE
        end
        sub_customized_config = CustomizedConfig::new(@workspace, path, customized_config)
        task_configs += sub_customized_config.get_task_configs
      end
      task_configs += get_task_configs
      
      task_configs.delete_if {|task_config| !task_config.vaild?}
    end
     
    def print
      print_json @config
    end
    
    
    class TaskConfig
      def initialize(config)
        @config = config
      end
      
      def vaild?
        @config.include?("build") || @config.include?("stage")
      end
      
      def [](k)
        @config[k]
      end
    end
  end
end
