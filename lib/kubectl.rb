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

    def self.get_secret_for(kube_host)
      puts "Retrieving custom env..."
      cmd = "kubectl get secret #{kube_host.decidim_name}-custom-env -n #{kube_host.namespace} -o jsonpath='{.data}'"
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