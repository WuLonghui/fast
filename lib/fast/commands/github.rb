module Fast
  module Command
    class Github < Base 
      usage "github create status"
      desc 'Create status for Github'
      option "--state state", [:pending, :success, :failure], "The state of the status (pending, success, failure), default pending"
      option "--target-url url", "The target URL to associate with this status"
      def create_status(repo, sha) 
        state = options[:state] || :pending
        target_url = options[:target_url] || ""
        github_client.create_status(repo, sha, state, target_url)
        say "Success"
      end
    end
  end
end