
# global conf
#working_directory APP_ROOT
timeout 30

if ENV['RACK_ENV'] == "production"
  # production conf
  worker_processes 2
  share = "/home/jmervine/ditty/shared"
  stderr_path "#{share}/log/unicorn_stderr.log"
  stdout_path "#{share}/log/unicorn_stdout.log"
  listen "#{share}/sockets/unicorn.sock", :backlog => 64
  pid "#{share}/log/unicorn.pid"
else
  # non-prod conf
  APP_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
  stderr_path APP_ROOT+"/log/unicorn_stderr.log"
  stdout_path APP_ROOT+"/log/unicorn_stdout.log"
  pid APP_ROOT+"/log/unicorn.pid"
  worker_processes 1
  listen 9001
end

