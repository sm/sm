rails_env = ENV["RAILS_ENV"] || "production"
project   = ENV["project"] || raise "The 'project' environment variable must be set."
prefix    = (%x{uname}.strip == "Linux") ? "/home/#{project}/shared" : "tmp/"

@config = {
  :preload_app => { "development" => false, "qa" => true, "ci" => true, "staging" => true, "production" => true },
  :pid => { "development" => "#{prefix}/#{project}.pid", "ci" => "#{prefix}/#{project}.pid", "qa" => "#{prefix}/#{project}.pid", "staging" => "#{prefix}/#{project}.pid", "production" => "#{prefix}/#{project}.pid" },
  :listen => { "development" => "#{prefix}/#{project}.sock", "ci" => "#{prefix}/#{project}.sock", "qa" => "#{prefix}/#{project}.sock", "staging" => "#{prefix}/#{project}.sock", "production" => "#{prefix}/#{project}.sock" },
  :worker_processes => { "development" => 2, "ci" => 1, "qa" => 2, "staging" => 2, "production" => 6 }
}

preload_app @config[:preload_app][rails_env]
pid @config[:pid][rails_env]
worker_processes @config[:worker_processes][rails_env]
listen @config[:listen][rails_env], :backlog => 2048 # :tcp_nopush => true

timeout 45

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
