module Fast
  class TaskWorkspace  
  
    attr_accessor :host_workspace, :container_workspace
    attr_accessor :host_scripts_dir, :container_scripts_dir
    attr_accessor :output, :host_output, :container_output
      
    def initialize(workspace, task)
      path = task.path
      
      @host_workspace = File.expand_path(File.join(workspace.host_workspace, path))
      @container_workspace = File.expand_path(File.join(workspace.container_workspace, path))
      
      tmp_dir = ENV["TMPDIR"] || "/tmp"
      @task_dir = File.join(tmp_dir, "tasks", task.index.to_s)
      FileUtils.rm_rf(@task_dir) if File.exist?(@task_dir)
      
      @host_scripts_dir = File.join(@task_dir, "scripts")
      @container_scripts_dir = @host_scripts_dir
      
      FileUtils.mkdir_p(@host_scripts_dir) 
      
      @host_output = File.join(workspace.host_workspace, workspace.output_dir)
      @container_output = File.join(workspace.container_workspace, workspace.output_dir)
    end
  end
end
