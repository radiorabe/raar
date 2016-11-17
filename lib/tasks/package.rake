desc 'Create a deployable artifact of the entire rails application'
task :package do
  rev_file = 'dist/REVISION'
  revision = `git rev-parse HEAD`
  next if File.exists?(rev_file) && revision == File.read(rev_file)

  rm_rf 'dist'
  mkdir 'dist'

  # compose contents
  sh 'git archive --format=tar HEAD | (cd dist && tar -xf -)'
  Bundler.with_clean_env do
    sh 'cd dist && RAILS_ENV=production bundle package --all-platforms'
  end
  sh 'rm -rf dist/.bundle'
  File.write(rev_file, revision)

  # create artifact
  sh 'cd dist && ' \
     'tar -cvzf raar.tar.gz ' \
     '--exclude tmp --exclude test --exclude .travis.yml --exclude .rubocop.yml ' \
     '.'
end
