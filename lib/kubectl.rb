require "open3"
require "json"
require "ostruct"

module Lib
  module Kubectl
    class Error < StandardError; end

    def self.get_hosts
      puts "Retrieving all hosts..."
      cmd = "kubectl get decidim --all-namespaces -o json"
      kubectl_exec!(cmd)
    end

    private

    def self.kubectl_exec!(cmd)
      stdout, stderr, status = Open3.capture3(cmd)

      OpenStruct.new(
        stdout: stdout,
        stderr: stderr,
        status: status
      )
    end
  end
end