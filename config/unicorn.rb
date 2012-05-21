APP_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))

# global conf
working_directory APP_ROOT
pid APP_ROOT+"/log/unicorn.pid"
stderr_path APP_ROOT+"/log/unicorn_stderr.log"
stdout_path APP_ROOT+"/log/unicorn_stdout.log"
timout 30

if ENV['RACK_ENV'] == "production"
  # production conf
  worker_processes 2
  listen "/home/jmervine/ditty/shared/sockets/unicorn.sock", :backlog => 64
else
  # non-prod conf
  worker_processes 1
  listen 9001
end

