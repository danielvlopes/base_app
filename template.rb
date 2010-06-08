# bundler
run "rm -Rf Gemfile"
get "http://github.com/danielvlopes/base_app/raw/master/Gemfile", "Gemfile"
run "bundle install"

# capistrano
capify!
get "http://github.com/danielvlopes/base_app/raw/master/config/deploy.rb", "config/deploy.rb"

# other downloads
get "http://github.com/danielvlopes/base_app/raw/master/config/locales/pt-BR.yml", "config/locales/pt-BR.yml"
get "http://github.com/danielvlopes/base_app/raw/master/lib/backup.rb", "lib/backup.rb"
get "http://github.com/danielvlopes/base_app/raw/master/app/views/layouts/maintenance.html.erb", "app/views/layouts/maintenance.html.erb"
get "http://github.com/danielvlopes/base_app/raw/master/app/views/layouts/application.html.erb", "app/views/layouts/application.html.erb"
get "http://github.com/danielvlopes/base_app/raw/master/app/helpers/application_helper.rb", "app/helpers/application_helper.rb"

# public folder
run "rm -Rf public/index.html"
get "http://github.com/danielvlopes/base_app/raw/master/public/stylesheets/application.css", "public/stylesheets/application.css"
get "http://github.com/danielvlopes/base_app/raw/master/public/stylesheets/global.css", "public/stylesheets/global.css"
get "http://github.com/danielvlopes/base_app/raw/master/public/images/ua_ch.jpg", "public/images/ua_ch.jpg"
get "http://github.com/danielvlopes/base_app/raw/master/public/images/ua_ff.jpg", "public/images/ua_ff.jpg"
get "http://github.com/danielvlopes/base_app/raw/master/public/images/ua_ie.jpg", "public/images/ua_ie.jpg"
get "http://github.com/danielvlopes/base_app/raw/master/public/images/ua_op.jpg", "public/images/ua_op.jpg"
get "http://github.com/danielvlopes/base_app/raw/master/public/images/ua_sf.jpg", "public/images/ua_sf.jpg"
get "http://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"
run "mkdir public/javascripts/lib public/javascripts/plugins"

# test
generate "rspec:install"
generate "steak"

application  <<-GENERATORS
config.generators do |g|
  g.test_framework  :rspec, :fixture => false, :views => false
  g.fixture_replacement :factory_girl, :dir => "spec/support/factories"
end
GENERATORS

# git
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
file '.gitignore', <<-END
config/database.yml
db/schema.rb
db/schema.sql
coverage/*
doc/*
log/*.log
log/*.out
log/*.pid
tmp/**/*
tmp/.*
tmp/profile*
uploads/*
vendor/**/**/doc/*
.DS_Store
.project
ssl/*
Icon?
END

git :init
git :add => '.'
git :commit => '-am "Initial commit"'

puts "=================================="
puts "SUCCESS"