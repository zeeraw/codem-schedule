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
preload_app false

# Set timeout which the old Unicorn workers will die.
timeout 45

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
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      `echo failed to kill unicorn on pid: #{old_pid}`
    end
  end

end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  `echo #{Process.pid} > #{child_pid}`
end
