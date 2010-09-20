namespace :deploy do
  namespace :config do

    namespace :mail do
      desc "Write smtp.rb on shared"
      task :create, :except => { :no_release => true } do
        location = fetch(:template_dir, "config/deploy/templates") + '/smtp.rb.erb'
        template = File.read(location)
        config = ERB.new(template)

        address   = Capistrano::CLI.ui.ask('What is the domain (ex myapp.com)? ')
        user_name = Capistrano::CLI.ui.ask('What is the user name(ex myuser@gmail.com)? ')
        password  = Capistrano::CLI.ui.ask('What is the password? ')

        run "mkdir -p #{shared_path}/config/initializers"
        put config.result(binding), "#{shared_path}/config/initializers/smtp.rb"
      end

      desc "Link smtp.rb on shared"
      task :symlink do
        run """
        rm -f #{release_path}/config/initializers/smtp.rb ;
        ln -nsf #{shared_path}/config/initializers/smtp.rb #{release_path}/config/initializers/smtp.rb
        """
      end
    end

    namespace :newrelic do
      desc "Write newrelic.yml on shared"
      task :create, :except => { :no_release => true } do
        location = fetch(:template_dir, "config/deploy/templates") + '/newrelic.yml.erb'
        template = File.read(location)
        config = ERB.new(template)

        api_key = Capistrano::CLI.ui.ask('What is the newrelic api_key?: ')
        environment_name = Capistrano::CLI.ui.ask('What is the stage?: ')

        run "mkdir -p #{shared_path}/config"
        put config.result(binding), "#{shared_path}/config/newrelic.yml"
      end

      desc "Link newrelic.yml on shared"
      task :symlink do
        run """
        rm -f #{release_path}/config/newrelic.yml ;
        ln -nsf #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml
        """
      end
    end

    namespace :hoptoad do
      desc "Write hoptoad.rb on shared"
      task :setup, :except => { :no_release => true } do
        location = fetch(:template_dir, "config/deploy/templates") + '/hoptoad.rb.erb'
        template = File.read(location)
        config = ERB.new(template)

        api_key = Capistrano::CLI.ui.ask('What is the hoptoad api_key?: ')
        environment_name = Capistrano::CLI.ui.ask('What is the stage?: ')

        run "mkdir -p #{shared_path}/config/initializers"
        put config.result(binding), "#{shared_path}/config/initializers/hoptoad.rb"
      end

      desc "Link hoptoad.rb to shared"
      task :symlink do
        run """
        rm -f #{release_path}/config/initializers/hoptoad.rb ;
        ln -nsf #{shared_path}/config/initializers/hoptoad.rb #{release_path}/config/initializers/hoptoad.rb
        """
      end
    end

    namespace :db do
      desc <<-DESC
      Creates the database.yml configuration file in shared path.

      By default, this task uses a template unless a template \
      called database.yml.erb is found either is :template_dir \
      or /config/deploy folders. The default template matches \
      the template for config/database.yml file shipped with Rails.

    When this recipe is loaded, db:setup is automatically configured \
    to be invoked after deploy:setup. You can skip this task setting \
    the variable :skip_db_setup to true. This is especially useful \
    if you are using this recipe in combination with \
    capistrano-ext/multistaging to avoid multiple db:setup calls \
    when running deploy:setup for all stages one by one.
      DESC
      task :create, :except => { :no_release => true } do

        default_template = <<-EOF
        base: &base
        adapter: sqlite3
        timeout: 5000
        development:
        database: #{shared_path}/db/development.sqlite3
        <<: *base
        test:
        database: #{shared_path}/db/test.sqlite3
        <<: *base
        production:
        database: #{shared_path}/db/production.sqlite3
        <<: *base
        EOF

        location = fetch(:template_dir, "config/deploy/templates") + '/database.yml.erb'
        template = File.file?(location) ? File.read(location) : default_template
        stage = Capistrano::CLI.ui.ask('What is the stage?: ')

        config = ERB.new(template)

        run "mkdir -p #{shared_path}/db"
        run "mkdir -p #{shared_path}/config"
        put config.result(binding), "#{shared_path}/config/database.yml"
      end

      desc "[internal] Updates the symlink for database.yml file to the just deployed release."
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      end
    end

  end
end

after "deploy:setup" do
  deploy.config.mail.create      unless fetch(:skip_mail_setup, false)
  deploy.config.newrelic.create  unless fetch(:skip_newrelic_setup, false)
  deploy.config.hoptoad.create   unless fetch(:skip_hoptoad_setup, false)
  deploy.config.db.create        unless fetch(:skip_db_setup, false)
end

after "deploy:finalize_update" do
  deploy.config.newrelic.symlink
  deploy.config.mail.symlink
  deploy.config.hoptoad.symlink
  deploy.config.db.symlink
end