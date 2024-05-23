#!/usr/bin/env ruby

require 'open3'
require "yaml"
require "base64"
require "uri"
require_relative "lib/kubectl"
require_relative "lib/kube_host"

host = if URI.parse(ARGV[0]).is_a?(URI::Generic)
         ARGV[0]
       else
         URI.parse(ARGV[0]).host
       end

if host.nil? || host.empty?
  puts "No hosts requested, end of process !"
  puts "Usage: ./main.rb <host>"
  return
end

puts "Looking for Kubernetes host..."
syscmd = Lib::Kubectl.get_hosts

unless syscmd.status.success?
  puts "kubectl failed unexpectedly!"
  puts "stderr:
#{syscmd.stderr}"
  return
end

hosts = JSON.parse(syscmd.stdout)&.fetch("items", []).map { |item| Lib::KubeHost.from_hash(item) }
targets = hosts.select { |format| host.include?(format.host) }

if targets.empty?
  puts "'#{host}' not found"
  return
end

targets.each do |target|
  target.print
end