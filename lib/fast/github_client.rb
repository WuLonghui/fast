module Fast
  class GithubClient
    def initialize(options)
      @client = Octokit::Client.new(options)
      @client.user
    rescue Octokit::Unauthorized => err
      raise Fast::GithubBadCredentials, "Bad credentials for Github"
    end
    
    def create_status(repo, sha, state, target_url)
      descriptions = {
        :pending => "The fast build is running",
        :success => "The fast build succeeded",
        :failure => "The fast build failed"
      }
      
      info = {
        "state"=> state,
        "target_url"=> target_url,
        "description"=> descriptions[state],
        "context"=> "Devops/fast"
      }
      
      @client.create_status(repo, sha, state, info)
    end
  end
end
