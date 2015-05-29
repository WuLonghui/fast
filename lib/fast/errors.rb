module Fast
  class FastError < StandardError
    attr_reader :exit_code

    def initialize(*args)
      @exit_code = 1
      super(*args)
    end

    def self.error_code(code = nil)
      define_method(:error_code) { code }
    end

    def self.exit_code(code = nil)
      define_method(:exit_code) { code }
    end

    error_code(42)
  end

  class UnknownCommand       < FastError; error_code(100); end
  class FileNotFound         < FastError; error_code(101); end  
  class GithubBadCredentials < FastError; error_code(102); end
end
  
module FastErrorsExtensions
  def err(message)
    raise Fast::FastError, message
  end
end

class Object
  include FastErrorsExtensions
end
