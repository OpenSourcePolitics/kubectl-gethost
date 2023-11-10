module Lib
  class KubeHost < OpenStruct
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
Image: #{image}
Version: #{version}
"
    end
  end
end