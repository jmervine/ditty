APP_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
worker_processes 1
listen 9001
pid APP_ROOT+"/log/unicorn.pid"
stderr_path APP_ROOT+"/log/unicorn_stderr.log"
stdout_path APP_ROOT+"/log/unicorn_stdout.log"

