# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, 'authorisation_server'
set :repo_url, 'git@10.190.0.129:authorisation_server'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

@known_hosts = ['manasbapps', 'vm']
@config_host = @known_hosts[0]

# Default deploy_to directory is /var/www/my_app_name
if @config_host == 'vm'
  set :deploy_to, '/home/cls/apps/rails/authorisation_server'
  @host1 = 'cls@10.191.0.150'
elsif @config_host == 'manasbapps'
  set :deploy_to, '/home/rec/apps/rails/authorisation_server'
  @host1 = 'rec@manasbapps'
else
  raise 'unexpected config host'
end

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
append :linked_files, 'config/secrets.yml', 'db/production.sqlite3'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# look for rvm in home folder
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.4.5@authorisation_server'

set :passenger_restart_with_touch, true
