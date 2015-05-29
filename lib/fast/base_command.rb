module Fast
  module Command
    class Base
      extend Fast::CommandDiscovery
      
      attr_accessor :options, :out, :args
      attr_reader :work_dir, :exit_code, :runner
      
      def initialize(runner = nil)
        @runner = runner
        @options = {}
        @work_dir = Dir.pwd
        @exit_code = 0
        @out = nil
        @args = []
      end
 
      def interactive?
        true
      end
      
      def add_option(name, value)
        @options[name] = value
      end
      
      def docker_client
        @docker_client ||= DockerClient.create(ENV["DOCKER_HOST"] || "unix:///run/docker.sock", :read_timeout => 600)
      end
      
      def github_client
        @github_client ||= Fast::GithubClient.new(Config.github.symbolize_keys!)
      end
      
      def parse_customized_config(workspace, customized_config_file)
        customized_config = CustomizedConfig.new(workspace, ".", customized_config_file)
        
        print_header "Customized Config:" 
        customized_config.print
        
        tasks = []
        task_configs = customized_config.parse
        task_configs.each_index do |index|
            task_config = task_configs[index]
            task = Task.new(index, task_config, workspace, docker_client)
            tasks << task
        end
        tasks
      end
    end
  end
end
