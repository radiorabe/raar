namespace :artifact do
  desc 'Check that the repo is reachable'
  task :check do
  end

  desc 'Copy repo to releases'
  task :create_release do
    on release_roles(:all) do |host|
      archive = fetch(:artifact_file, 'build/raar.tar.gz')
      compression = fetch(:artifact_compression, 'gz')
      tar_option =
        case compression
        when 'gz' then 'z'
        when 'xz' then 'J'
        end

      file_location = "/tmp/build-artifact-files/build-artifact.tar.#{compression}"
      execute :mkdir, '-p', File.dirname(file_location)
      #execute :rm, "-f #{file_location}"

      #upload! archive, file_location

      execute :mkdir, '-p', release_path
      within release_path do
        execute :tar, "-x#{tar_option}f '#{file_location}'"
      end
      #execute :rm, file_location
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    on release_roles(:all) do |host|
      within release_path do
        set :current_revision, capture(:cat, 'REVISION')
      end
    end
  end
end
