#!/usr/bin/env ruby -wKU
require 'yaml'
require 'erb'

operation, deploy_to = ARGV
cfg = YAML::load(ERB.new(IO.read("#{deploy_to}/shared/database.yml")).result)
exit 0 unless cfg['production'] # get out if dont find database.yml
prd = cfg['production']
mysql_opts = "-u #{prd['username']} -p#{prd['password']} #{prd['database']}"

commands = []

case operation
when 'backup'
  commands << "test -d #{deploy_to}/etc || mkdir -pm 755 #{deploy_to}/etc"  
  commands << "mysqldump #{mysql_opts} > #{deploy_to}/etc/dump.sql"
  commands << "cd #{deploy_to}/etc && tar cvfz dump.tar.gz dump.sql"
  commands << "rm #{deploy_to}/etc/dump.sql"
when 'restore'
  commands << "cd #{deploy_to}/etc && if [ -f dump.tar.gz ]; then tar xvfz dump.tar.gz dump.sql ; fi"
  commands << "if [ -f #{deploy_to}/etc/dump.sql ]; then mysql -u #{mysql_opts} < #{deploy_to}/etc/dump.sql && rm #{deploy_to}/etc/dump.sql ; fi"
end

commands.each do |cmd|
  puts "running: #{cmd.gsub(prd['password'], '*****')}"
  `#{cmd}`
end
puts "#{operation} finished sucessfuly."
