module Fast
  module Utils
    def self.load_yaml_file(path)
      YAML.load_file(path)
    end
  end
  
  module Dir 
    def self.pwd
      ENV['PWD'] || Dir.pwd
    end
  end
end

module HashExtensions 
  def symbolize_keys!
    self.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end  
end

class Hash
  include HashExtensions
end
