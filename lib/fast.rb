require "optparse"
require "yaml"
require "json"
require "docker_client"
require "work_queue"
require 'highline/import'
require "octokit"
require 'digest/sha1'
require 'find'

require "fast/version"
require "fast/utils"
require "fast/output"
require "fast/errors"
require "fast/script_generator"
require "fast/workspace"
require "fast/task_workspace"
require "fast/task"
require "fast/task_executor"
require "fast/config"
require "fast/customized_config"
require "fast/runner"
require "fast/github_client"

require "fast/command_handler"
require "fast/command_discovery"
require "fast/base_command"

tmpdir = Dir.mktmpdir
at_exit { FileUtils.rm_rf(tmpdir) }
ENV['TMPDIR'] = tmpdir

Dir[File.dirname(__FILE__) + '/fast/commands/**/*.rb'].each do |file|
  require file
end

module Fast
end

