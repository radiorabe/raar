# This file will be included by default when someone sets the scm to be :artifact

load File.expand_path('../tasks/artifact.rake', __FILE__)

# These two tasks are unnecessary for this strategy
#Rake::Task['deploy:log_revision'].clear
#Rake::Task['deploy:set_current_revision'].clear
#namespace :deploy do
#  task :set_current_revision do
#  end
#  task :log_revision do
#  end
#end
