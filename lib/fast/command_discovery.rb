module Fast
  module CommandDiscovery
    def usage(string = nil)
      @usage = string
    end

    def desc(string)
      @desc = string
    end

    def option(name, *args)
      (@options ||= []) << [name, args]
    end

    def method_added(method_name)
      if @usage && @desc
        @options ||= []
        method = instance_method(method_name)
        register_command(method, @usage, @desc, @options)
      end
      @usage = nil
      @desc = nil
      @options = []
    end


    def register_command(method, usage, desc, options = [])
      command = CommandHandler.new(self, method, usage, desc, options)
      Fast::Config.register_command(command)
    end
  end
end
