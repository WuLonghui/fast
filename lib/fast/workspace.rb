module Fast
  class Workspace 
    
    attr_accessor :origin_dir, :output_dir
    attr_accessor :host_workspace, :container_workspace
    
    def initialize(origin_dir, output_dir = nil)
      @origin_dir = File.expand_path(origin_dir, Dir.pwd)
      @output_dir = output_dir || "output"
      unless File.exist?(@origin_dir)
        err "workspace(#{@origin_dir}) not found"
      end  
      
      @host_workspace = @origin_dir
      @container_workspace = "/workspace"             
    end
    
    def releases
      File.join(@host_workspace, "releases")
    end
    
    def dev_releses
      File.join(@host_workspace, "dev_releases") 
    end
    
    def task_workspace(task)
       TaskWorkspace.new(self, task)
    end
    
  end
end
