namespace :deploy do
  namespace :web do
    task :disable, :roles => :web do
      on_rollback { rm "#{shared_path}/system/maintenance.html" }

      require 'erb'
      deadline, reason = ENV['UNTIL'], ENV['REASON']
      maintenance = ERB.new(File.read("./config/deploy/templates/maintenance.html.erb")).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end