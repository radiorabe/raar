before 'deploy:starting', 'build:artifact' do
  run_locally do
    execute 'bundle exec rails build'
  end
end
