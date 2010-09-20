namespace :log do
  desc "tail log files"
  task :tail, :roles => :app do
    run "tail -f #{shared_path}/log/*.log" do |channel, stream, data|
      puts # blank line
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
end