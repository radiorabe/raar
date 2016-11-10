desc 'Create a deployable artifact of the entire rails application'
task :build do
  rev_file = 'build/REVISION'
  revision = `git rev-parse HEAD`
  next if File.exists?(rev_file) && revision == File.read(rev_file)

  rm_rf 'build'
  mkdir 'build'

  # compose contents
  sh 'git archive --format=tar HEAD | (cd build && tar -xf -)'
  Bundler.with_clean_env do
    sh 'cd build && RAILS_ENV=production bundle package --all-platforms'
  end
  sh 'rm -rf build/.bundle'
  File.write(rev_file, revision)

  # create artifact
  sh 'cd build && ' \
     'tar -cvzf raar.tar.gz ' \
     '--exclude tmp --exclude test --exclude .travis.yml --exclude .rubocop.yml ' \
     '.'
end
