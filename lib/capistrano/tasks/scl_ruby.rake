
namespace :scl_ruby do
  desc 'Prints the Ruby version on the target host'
  task :check do
    on roles(:all) do
      puts capture(:ruby, '--version') if fetch(:log_level) == :debug
    end
  end

  task :hook do
    scl_prefix = "source #{fetch(:scl_ruby_home)}/enable && "
    fetch(:scl_map_bins).each do |command|
      SSHKit.config.command_map.prefix[command.to_sym].unshift(scl_prefix)
    end
  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'scl_ruby:hook'
  after stage, 'scl_ruby:check'
end

namespace :load do
  task :defaults do
    set :scl_map_bins, %w(gem rake ruby bundle)
    set :scl_ruby_home, '/opt/rh/rh-ruby22'
  end
end
