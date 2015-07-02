#!/usr/bin/env ruby

require 'thor'
require 'tomlrb'
require 'ffi_yajl'

class SpinCycle < Thor
  include Thor::Actions

  method_option :server_url, aliases: "-u", desc: "The URL of your chef server"
  method_option :client_name, aliases: "-c", desc: "The client to connect to chef server with"
  method_option :client_key, aliases: "-k", desc: "The path to the client key"
  desc "configure", "Configure Spin Cycle defaults"
  def configure
    conf = <<-EOH
[main]
url = "#{options[:server_url]}"
client = "#{options[:client_name]}"
key = "#{options[:client_key]}"
    EOH
    File.open("config.toml", "w") {|f| f.write(conf)}
  end

  desc "sync", "synchronize stress cookbook with hosted chef"
  def sync
    inside('stress') do
      run('berks install')
      run('berks upload --force')
    end
  end

  desc "destroy", "Destroy all nodes"
  def destroy
    run('chef-client -j spincycle.json -z destroy.rb')
  end

  desc "launch VERSION", "launch Spin Cycle with the appropriate Chef version"
  method_option :ssh_key, aliases: "-x", desc: "The ssh key to use"
  def launch(version)
    cfg = Tomlrb.parse(File.open(File.expand_path('./config.toml')))["main"]
    json = FFI_Yajl::Encoder.encode( {  bootstrap_url: cfg["url"], bootstrap_client: cfg["client"], bootstrap_key: cfg["key"],  "chef_client_version" => version, "ssh_key" => options[:ssh_key] }, {})
    File.open("spincycle.json", "w") { |f| f.write(json)}
    run('chef-client -j spincycle.json -z bootstrap.rb')
  end
end

SpinCycle.start(ARGV)
