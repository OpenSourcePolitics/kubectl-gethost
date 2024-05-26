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

    def set_maintenance_pod_cmd(duration = 30)
      puts "Creating a new maintenance pod..."
      puts "> Duration: #{duration} minutes"
      cmd = "kubectl annotate decidim -n #{self.namespace} #{self.decidim_name} decidim.libre.sh/maintenance=#{duration}"
      puts "> #{cmd}"

      puts "Do you want to continue ? (y/n)"
      answer = STDIN.gets.chomp
      if answer != "y" || answer != "yes" || answer != "Y" || answer != "Yes"
        return OpenStruct.new(stderr: "Aborted !")
      end
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