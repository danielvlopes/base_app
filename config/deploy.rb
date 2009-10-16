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
set :deploy_to, "~/#{application}"
set :shared_directory, "#{deploy_to}/shared"
set :use_sudo, false
set :group_writable, false
default_run_options[:pty] = true

# ROLES
role :app, domain_name
role :web, domain_name
role :db,  domain_name, :primary => true

#TASKS
task :after_update_code, :roles => [:web, :db, :app] do
  run "chmod 755 #{release_path}/public"
  db.upload_database_yaml
  assets.package
end

namespace :deploy do
  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  namespace :web do
    task :disable, :roles => :web do
      on_rollback { rm "#{shared_path}/system/maintenance.html" }

      require 'erb'
      deadline, reason = ENV['UNTIL'], ENV['REASON']
      maintenance = ERB.new(File.read("./app/views/layouts/maintenance.html.erb")).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end  
end

namespace :log do
  desc "tail production log files"
  task :tail, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # para uma linha extra
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
end

namespace :ssh do
  desc "upload you public ssh key"
  task :upload_key, :roles => :app do
    public_key_path = File.expand_path("~/.ssh/id_rsa.pub")
    unless File.exists?(public_key_path)
      puts %{
        Public key not found #{public_key_path}
        Create your key - without passphrase:
          ssh_keygen -t rsa
      }
      exit 0
    end
    ssh_path = "/home/#{user}/.ssh"
    run "test -d #{ssh_path} || mkdir -pm 755 #{ssh_path}"
    upload public_key_path, "#{ssh_path}/../id_rsa.pub"
    run "test -f #{ssh_path}/authorized_keys || touch #{ssh_path}/authorized_keys"
    run "cat #{ssh_path}/../id_rsa.pub >> #{ssh_path}/authorized_keys"
    run "chmod 755 #{ssh_path}/authorized_keys"
    run "rm #{ssh_path}/../id_rsa.pub"    
  end
end

namespace :assets do
 desc "create asset packages for production"
 task :package, :roles => :web do
   run "cd #{current_path} && rake asset:packager:build_all"
 end
end

namespace :db do

  desc "remote backup and download the MySQL database"
  task :backup, :roles => :db do
    backup_rb ||= "#{current_path}/lib/backup.rb"
    run "if [ -f #{backup_rb} ]; then ruby #{backup_rb} backup #{deploy_to} ; fi"
    get "#{deploy_to}/etc/dump.tar.gz", "#{Date.today.to_s}.tar.gz"
    run "rm #{deploy_to}/etc/dump.tar.gz"
  end

  desc "upload and restore of remote MySQL database"
  task :restore, :roles => :db do
    unless File.exists?("dump.tar.gz")
      puts "Backup dump.tar.gz not found"
      exit 0
    end
    backup_rb ||= "#{current_path}/lib/backup.rb"
    upload "dump.tar.gz", "#{deploy_to}/etc/dump.tar.gz"
    run "if [ -f #{backup_rb} ]; then ruby #{backup_rb} restore #{deploy_to} ; fi"
  end

  desc "upload database.yml"
  task :upload_database_yaml do
    upload File.join(File.dirname(__FILE__), "database.yml"), "#{shared_path}/database.yml"
    run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
  end

end