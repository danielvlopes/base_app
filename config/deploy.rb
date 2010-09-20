# APP SETTINGS
set :application, "APPNAME"
set :domain_name , "www.appname.com"

# GIT SETTINGS
set :scm, :git
set :repository,  "git@github.com:danielvlopes/REPO.git"
set :branch, "master"
set :deploy_via, :remote_cache

# SSH SETTINGS
set :user , "USERNAME"
set :deploy_to, "/home/#{application}"
set :shared_directory, "#{deploy_to}/shared"
set :use_sudo, false
set :group_writable, false
default_run_options[:pty] = true

# ROLES
role :app, domain_name
role :web, domain_name
role :db,  domain_name, :primary => true