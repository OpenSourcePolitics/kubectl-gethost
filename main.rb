#!/usr/bin/env ruby

require 'open3'
require "yaml"
require "byebug"
require_relative "lib/kubectl"
require_relative "lib/kube_host"
require "airbyte_ruby"

host = ARGV[0]

if host.nil? || host.empty?
  puts "No hosts requested, end of process !"
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

hosts = JSON.parse(syscmd.stdout)&.fetch("items", [])
hosts = hosts.map { |host| Lib::KubeHost.from_hash(host) }
targets = hosts.select { |format| host.include?(format.host) }

if targets.empty?
  puts "'#{host}' not found"
  return
end

targets.each do |target|
  target.print
end