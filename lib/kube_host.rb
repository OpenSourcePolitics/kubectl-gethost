module Lib
  class KubeHost < OpenStruct
    include Kubectl

    OWNER = "OpenSourcePolitics"
    def self.from_hash(hash)
      new(
        id: hash["metadata"]["uid"],
        decidim_name: hash["metadata"]["name"],
        namespace: hash["metadata"]["namespace"],
        status: hash["status"]["phase"],
        host: hash["spec"]["host"],
        image: hash["spec"]["image"],
        version: hash["status"]["version"],
      )
    end

    def print
      puts "
Host: #{host}
Namespace: #{namespace}
Decidim Operator: #{decidim_name}
Github: #{github_url}
Image: #{image}
Version: #{version}
"
    end

    def get_secrets
      cmd = self.get_secrets_cmd.stdout
      JSON.parse(cmd).each do |key, value|
        puts "#{key}: #{Base64.decode64(value)}"
      end
    end

    def set_maintainance_pod(duration = 30)
      cmd = self.set_maintenance_pod_cmd(duration)
      if !cmd.stderr.nil?
        puts cmd.stderr
        return
      else
          puts cmd.stdout
          puts "Maintenance pod created !"
      end
    end

    private

    def github_url
      project = image.split(":")[0].split("/")[-1]
      v = if version.split(".").size === 3
            "v#{version}"
          else
            version
          end
      "https://github.com/#{OWNER}/#{project}/tree/#{v}"
    end
  end
end