# encoding: utf-8
# Full documentation for Unicorn configuration can be found at:
# http://unicorn.bogomips.org/Unicorn/Configurator.html
#
# By default the environment is production.
env = ENV["RAILS_ENV"] || "production"

# Set up a project root path
PROJECT_ROOT = File.expand_path("..",File.dirname(__FILE__)) unless defined? PROJECT_ROOT

# Select how many unicorn workers should spawn.
worker_processes ENV["UNICORN_PROCESSES"].to_i || 8

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
socket_path = ENV["UNICORN_SOCKET"] || "#{PROJECT_ROOT}/tmp/sockets/unicorn.socket"
listen socket_path, :backlog => 256

# Preload our app for more speed
preload_app true

# Set timeout which the old Unicorn workers will die.
timeout 15

# Setup the path for unicorn pid-files.
pid_path = ENV["UNICORN_PID"] || "#{PROJECT_ROOT}/tmp/pids/unicorn.pid"
pid pid_path

# Setup the working directory for the application.
working_directory ENV["UNICORN_WORKING_DIR"] || PROJECT_ROOT

# Setup access and error logging for the Unicorn master process.
stderr_path ENV["UNICORN_STDERR"] || "#{PROJECT_ROOT}/tmp/log/unicorn.stderr.log"
stdout_path ENV["UNICORN_STDOUT"] || "#{PROJECT_ROOT}/tmp/log/unicorn.stdout.log"

# Fork the thread and start Unicorn in sub-processes
before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid_path = pid_path + ".old"
  if File.exists?(old_pid_path) && server.pid != old_pid_path
    begin
      Process.kill("QUIT", File.read(old_pid_path).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      `echo failed to kill unicorn on pid: #{old_pid_path}`
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
