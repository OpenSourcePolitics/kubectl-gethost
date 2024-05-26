#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'yaml'
require 'base64'
require 'uri'
require_relative 'lib/kubectl'
require_relative 'lib/kube_host'

def flags(args)
  flags = {}

  args.each do |arg|
    case arg
    when '--help', '-h'
      puts "Usage: kubectl-gethost <host>

OPTIONS:

  --help, -h: Show this help message
  --secrets, -s: Show secrets for the host
  --interactive, -i: Set a maintenance pod for the host
  --duration, -d: Set a duration for the maintenance pod
"
      exit 1
    when '--secrets', '-s'
      flags[:secrets] = true
    when '--interactive', '-i'
      flags[:maintainance] = true
    when '--duration', '-d'
      flags[:duration] = args[args.index(arg) + 1].to_i
      if flags[:duration].nil? || flags[:duration] <= 0
        puts 'Duration must be a positive integer'
        exit 1
      end
    end
  end

  flags
end

host = if URI.parse(ARGV[0] || '').is_a?(URI::Generic)
         ARGV[0]
       else
         URI.parse(ARGV[0]).host
       end

flags = flags(ARGV)

if host.nil? || host.empty?
  puts 'No hosts requested, end of process !'
  puts "Usage: kubectl-gethost <host>

OPTIONS:

  --help, -h: Show this help message
  --secrets, -s: Show secrets for the host
  --interactive, -i: Set a maintenance pod for the host
  --duration, -d: Set a duration for the maintenance pod
"
  exit 1
end

puts 'Looking for Kubernetes host...'
syscmd = Lib::Kubectl.get_hosts

unless syscmd.status.success?
  puts 'kubectl failed unexpectedly!'
  puts "stderr:
#{syscmd.stderr}"
  return
end

hosts = JSON.parse(syscmd.stdout)&.fetch('items', [])&.map { |item| Lib::KubeHost.from_hash(item) }
targets = hosts.select { |format| host.include?(format.host) }

if targets.empty?
  puts "'#{host}' not found"
  return
end

targets.each do |target|
  target.print
  target.get_secrets if flags[:secrets]
  duration = flags[:duration] || 30
  target.set_maintainance_pod(duration) if flags[:maintainance]
end
