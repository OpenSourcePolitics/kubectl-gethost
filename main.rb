#!/usr/bin/env ruby

require 'open3'
require "yaml"
require_relative "lib/kubectl"
require_relative "lib/kube_host"

host = ARGV[0]

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
  puts "Retrieving custom env..."
  syscmd = Lib::Kubectl.get_secret_for(target)
  puts syscmd.stdout
end