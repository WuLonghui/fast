module Fast
  module TaskExecutor
    def self.run(key, tasks, options)  
      if tasks.size == 1  then
        task = tasks.first
        task.run(key, {"streaming_logs" => true, "pull_policy" => options[:pull_policy]}) if task.run?(key)
      elsif tasks.size > 1
        exit_code = run_in_parallel(key, tasks, options)
      else # task.size == 0 
        return 0
      end
      
      exit_code = 0
      print_header "Result:"     
      tasks.each do |task|
        say task.info
        exit_code = task.exit_code if task.exit_code > 0 
      end
      exit_code
    end
    
    def self.run_in_parallel(key, tasks, options)
        work_queue_paras = options.fetch(:work_queue, []).map{|item| item.to_i }
        max_threads = work_queue_paras[0]
        max_tasks = work_queue_paras[1]
        wq = WorkQueue.new(max_threads, max_tasks)
        
        tasks.each do |task|
          next unless task.run?(key)
          wq.enqueue_b do
            begin 
              task.run(key, {"streaming_logs" => false, "pull_policy" => options[:pull_policy]}) 
              
              print_header task.info
              say task.logs
              nl 2
            rescue => err 
              say_error "task(#{task.index}) failed: #{err.to_s}"
              print_backtrace err
            end
          end
        end
        
        wq.join
      end
    
  end
end
