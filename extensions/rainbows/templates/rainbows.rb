#
# Setup
#
@user         = %x{whoami}.strip
@project      = ENV["project"]          || raise("The 'project' environment variable must be set.")
@project_path = ENV["project_path"]     || "/home/#{@user}"
@rails_env    = ENV["RAILS_ENV"] || ENV["RAILS_ENV"] || "production"
@timeout      = ENV["timeout"].to_i > 0 ? ENV["timeout"].to_i : 600 # 10 minutes
@prefix       = ["Linux","FreeBSD"].include?(%x{uname}.strip) ? "/home/#{@user}/shared" : "tmp/"

# Important for debugging during daemonization
stderr_path "#{@project_path}/shared/log/rainbows.error.log"
stdout_path "#{@project_path}/shared/log/rainbows.log"

#
# Configuration
#
@config = {
  :preload_app => { "development" => false, "qa" => true, "ci" => true, "staging" => true, "production" => true },
  :pid => { "development" => "#{@prefix}/pids/#{@project}.rainbows.pid", "ci" => "#{@prefix}/pids/#{@project}.rainbows.pid", "qa" => "#{@prefix}/pids/#{@project}.rainbows.pid", "staging" => "#{@prefix}/pids/#{@project}.rainbows.pid", "production" => "#{@prefix}/pids/#{@project}.rainbows.pid" },
  :listen => { "development" => "#{@prefix}/#{@project}.rainbows.sock", "ci" => "#{@prefix}/#{@project}.rainbows.sock", "qa" => "#{@prefix}/#{@project}.rainbows.sock", "staging" => "#{@prefix}/#{@project}.rainbows.sock", "production" => "#{@prefix}/#{@project}.rainbows.sock" },
  :worker_processes => { "development" => 2, "ci" => 2, "qa" => 2, "staging" => 2, "production" => 2 }
}

#
# Settings
#
preload_app @config[:preload_app][@rails_env]
pid @config[:pid][@rails_env]
worker_processes @config[:worker_processes][@rails_env]
listen @config[:listen][@rails_env], :backlog => 2048 # :tcp_nopush => true
timeout @timeout

Rainbows! do
  use :ThreadSpawn # concurrency model to use
  worker_connections 400
  keepalive_timeout 5 # 5 is default, zero disables keepalives entirely
  client_max_body_size 10*1024*1024 # 10 megabytes
end

# We are running on 1.9, no need to uncomment cow functionality.
# GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true
before_fork do |server, worker|
  # the following is recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.connection.disconnect!

  # the following allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end

    # optionally throttle the master from forking too quickly by sleeping
    sleep 1
  end
end

after_fork do |server, worker|
  # the following is required for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.establish_connection
end
