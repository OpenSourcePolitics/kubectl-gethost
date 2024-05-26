# frozen_string_literal: true

require 'open3'
require 'json'
require 'ostruct'

module Lib
  module Kubectl
    class Error < StandardError; end

    def self.get_hosts
      puts 'Retrieving all hosts...'
      cmd = 'kubectl get decidim --all-namespaces -o json'
      kubectl_exec!(cmd)
    end

    def get_secrets_cmd
      puts 'Retrieving custom env...'
      cmd = "kubectl get secret #{decidim_name}-custom-env -n #{namespace} -o jsonpath='{.data}'"
      Lib::Kubectl.kubectl_exec!(cmd)
    end

    def set_maintenance_pod_cmd(duration = 30)
      puts 'Creating a new maintenance pod...'
      puts "> Duration: #{duration} minutes"
      cmd = "kubectl annotate decidim -n #{namespace} #{decidim_name} decidim.libre.sh/maintenance=#{duration}"
      puts "> #{cmd}"

      puts 'Do you want to continue ? (y/n)'
      answer = $stdin.gets.chomp
      return OpenStruct.new(stderr: 'Aborted !') if answer != 'y' || answer != 'yes' || answer != 'Y' || answer != 'Yes'

      Lib::Kubectl.kubectl_exec!(cmd)
    end

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
