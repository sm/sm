#!/usr/bin/env ruby

#
# This config file was inspired by Github's Unicorn god config.
# It is meant to control unicorn_rails processes.
#

#
# Setup
#
@user         = %x{whoami}.strip
@project      = ENV["project"]          || raise("The project environment variable must be set.")
@project_path = ENV["project_path"]     || "/home/#{user}"
@rails_env    = ENV["RAILS_ENV"]        || "production"
@rails_root   = ENV["RAILS_ROOT"]       || "/home/#{user}/current"
@interval     = ENV["interval"].to_i    || 30
@memory_limit = ENV["memory_limit"]     || 300
@start_grace  = ENV["start_grace"].to_i || 10
@stop_grace   = ENV["stop_grace"].to_i  || 10
@pid_file     = ENV["pid_file"].to_i    || "#{project_path}/pids/unicorn.pid"
@uid          = ENV["uid"]              || @user
@gid          = ENV["gid"]              || @user

#
# Sanity Checks
#
raise("This bdsm god config is meant to be run as a non-root user.") if @user == "root"
raise("Interval must be a positive integer") if @interval <= 0


#
# Email Notifications
#
# Uncomment & change details to enable
#

# God::Contacts::Email.message_settings = {
#   :from => "god@example.com"
# }
#
# God::Contacts::Email.server_settings = {
#   :address => "smtp.example.com",
#   :port => 25,
#   :domain => "example.com",
#   :authentication => :plain,
#   :user_name => "god",
#   :password => "s3kr3t"
# }
#
# God.contact(:email) do |config|
#   config.name  = "admin"
#   config.email = "admin@example.com"
#   config.group = "admins"
# end
#
# God.contact(:email) do |config|
#   config.name  = "developer"
#   config.email = "vanpelt@example.com"
#   config.group = "developers"
# end

#
# Unicorn Herd Master
#
God.watch do |unicorn|
  unicorn.name          = "unicorn"
  unicorn.group         = "unicorns"
  unicorn.interval      = @interval.seconds
  unicorn.start_grace   = @start_grace.seconds
  unicorn.restart_grace = @stop_grace.seconds
  unicorn.pid_file      = @pid_file
  unicorn.uid           = @uid
  unicorn.gid           = @gid
  unicorn.start         = "bdsm unicorn start"
  unicorn.stop          = "bdsm unicorn stop"
  unicorn.stop          = "bdsm unicorn restart"

  unicorn.behavior(:clean_pid_file)

  unicorn.start_if do |start|
    start.condition(:process_running) do |config|
      config.interval = 5.seconds
      config.running  = false
    end
  end

  unicorn.restart_if do |restart|
    restart.condition(:memory_usage) do |config|
      config.above = @memory_limit.megabytes
      config.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |config|
      config.above = 50.percent
      config.times = 5
    end
  end

  # lifecycle
  unicorn.lifecycle do |on|
    on.condition(:flapping) do |config|
      config.to_state     = [:start, :restart]
      config.times        = 5
      config.within       = 5.minute
      config.transition   = :unmonitored
      config.retry_in     = 10.minutes
      config.retry_times  = 5
      config.retry_within = 2.hours
    end
  end

  # Uncomment when enabling email notifications.
  # unicorn.transition(:up, :start) do |on|
  #   on.condition(:process_exits) do |config|
  #     config.notify = {:contacts => ["admins", "developers"]
  #   end
  # end
end

#
# Unicorn Herd Workers
#
Thread.new do
  loop do
    begin
      %x{ps -e -www -o pid,rss,command | grep "[u]nicorn_rails worker" | grep #{@user}}.strip.split("\n").each do |line|
        worker_pid,worker_ram,worker_command = line.split(" ")
        if worker_ram.to_i > @memory_limit.megabytes
          ::Process.kill("QUIT", worker_pid.to_i) # signal worker to exit after serving it's current request
        end
      end
    rescue Object
      nil # Do not terminate the thread, regardless of error encountered.
    end
    sleep @interval
  end
end
