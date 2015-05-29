module Fast
  class Task
    attr_accessor :index, :path
    
    def initialize(index, config, workspace, docker_client)
      @index = index
      @config = config
      @path = @config["path"]
      @workspace = workspace
      @task_workspace = workspace.task_workspace(self)
      @docker_client = docker_client
      @exit_code = -1
    end
    
    def name
      @config["name"] || File.basename(@task_workspace.host_workspace) || ENV["JOB_NAME"] 
    end
    
    def info
      "Task #{name}/#{@index} (path: #{@path}, customized_config: #{@config["customized_config_file"]}, result: #{result})"
    end
    
    def run?(key)
      if @config[key].nil? then
        say_warning("Task #{name}/#{@index} #{key} script is empty")
        return false
      end
      
      return true
    end
    
    def run(key, options = {})
      image = @config["image"]
      begin
         say_debug("docker pull #{image}")
         pull_policy = options["pull_policy"] || "pull_always"
         @docker_client.pull(image, "pull_policy" =>  pull_policy )
      rescue Docker::Error::ImageBeingPulledError => err
         say_warning(err.message)
      end
      
      script_generator = ScriptGenerator.new(@task_workspace.host_scripts_dir, @task_workspace.container_scripts_dir, @config)
      build_script = script_generator.generate_script(key)
      command = ["/bin/bash", build_script, "2>&1"]

      volumes = [
        [@workspace.host_workspace, @workspace.container_workspace],
        [@task_workspace.host_output, @task_workspace.container_output],
        [@task_workspace.host_scripts_dir, @task_workspace.container_scripts_dir, "ro"]
      ]
      
      envs = {
        "WORKSPACE" => @task_workspace.container_workspace,
        "OUTPUT" => @task_workspace.container_output
      }.merge(@config["env"] || {})
      
      @container = @docker_client.run(image, command, "-v" => volumes, "-e" => envs, "-w" => @task_workspace.container_workspace, "--privileged" => true)
      say_debug("docker run #{@container.id}")
      
      @logs = String.new
      @container.streaming_logs(timestamps:0) do |_, chunk| 
        @logs << chunk
        say "#{chunk}" if options["streaming_logs"]
      end

      @exit_code = @container.exit_code
      
    ensure
      @container.remove("force" => true) if !@container.nil? && @container.exist?
    end
    
    def logs
      @logs || ""
    end
    
    def exit_code
      @exit_code
    end
    
    def result
      return "Unkown" if @exit_code == -1
      @exit_code == 0 ? "Success" : "Failure"
    end
    
    def path
      @path
    end
    
    def output
      @task_workspace.output
    end
  end
end
