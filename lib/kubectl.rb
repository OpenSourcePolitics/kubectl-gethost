require "open3"
require "json"
require "ostruct"

module Lib
  module Kubectl
    class Error < StandardError; end

    def self.get_hosts
      puts "Retrieving all hosts..."
      cmd = "kubectl get decidim --all-namespaces -o json"
      self.kubectl_exec!(cmd)
    end

    def get_secrets_cmd
      puts "Retrieving custom env..."
      cmd = "kubectl get secret #{self.decidim_name}-custom-env -n #{self.namespace} -o jsonpath='{.data}'"
      Lib::Kubectl.kubectl_exec!(cmd)
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