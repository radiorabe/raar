namespace :artifact do
  desc 'Check that the repo is reachable'
  task :check do
  end

  desc 'Copy repo to releases'
  task :create_release do
    on release_roles(:all) do
      archive = fetch(:artifact_file, 'build/raar.tar.gz')
      compression = fetch(:artifact_compression, 'gz')
      tar_option =
        case compression
        when 'gz' then 'z'
        when 'xz' then 'J'
        end

      file = "raar-#{fetch(:current_revision, 1).strip}.tar.#{compression}"
      folder = '/tmp/raar-build'
      path = "#{folder}/#{file}"
      puts path

      # upload artifact if not present yet
      execute :mkdir, '-p', folder
      unless test("[ -f '#{path}' ]")
        execute :rm, "-f #{folder}/*"
        upload! archive, path
      end

      # explode artifact to release_path
      execute :mkdir, '-p', release_path
      within release_path do
        execute :tar, "-x#{tar_option}f '#{path}'"
      end
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
  end
end
