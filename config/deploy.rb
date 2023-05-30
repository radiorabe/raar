# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '3.17.3'

set :application, 'raar'
set :repo_url, 'git@github.com:radiorabe/raar.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/raar'

# Default value for :scm is :git
# set :scm, :git
# set :scm, :artifact

set :bundle_config, { deployment: true, quiet: true, local: true }

# Restart passenger with `touch tmp/restart.txt`
# The alternative would be `passenger-config restart-app`
set :passenger_restart_with_touch, true

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto,
#     truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files,
       # 'config/database.yml',
       # 'config/secrets.yml',
       'config/show_names.yml',
       'config/initializers/exception_notification.rb'

# Default value for linked_dirs is []
append :linked_dirs,
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'public/system',
       'vendor/bundle'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
