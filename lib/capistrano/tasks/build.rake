before 'deploy:starting', 'build:artifact' do
  run_locally do
    execute 'bundle exec rails build'
    set :current_revision, File.read('build/REVISION')
  end
end
