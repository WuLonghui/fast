module Fast
  module Command
    class Stage < Base
      usage "stage"
      desc 'Fast Stage'
      option "--output dir", "The dir of Output, defaut output"
      option "--customized-config file", "Override customized config #{Fast::CustomizedConfig::CUSTOMIZED_CONFIG_FILE}"
      option "--work-queue max_threads,max_tasks", Array, "The parameters of WorkQueue"
      option "--pull-policy policy", ["pull_always", "pull_never", "pull_if_not_present"], "The policy of docker pull (pull_always, pull_never, pull_if_not_present), default pull_always"
      def stage(workspace = Dir.pwd)  
        workspace = Workspace.new(workspace, options[:output])

        tasks = parse_customized_config(workspace, options[:customized_config])
        
        print_header "Fast stage tasks(#{tasks.size})"  
        exit_code = TaskExecutor.run("stage", tasks, options)        
        exit exit_code          
      end
    end
  end
end

