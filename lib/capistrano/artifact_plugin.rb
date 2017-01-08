require 'capistrano/scm/plugin'

# http://capistranorb.com/documentation/advanced-features/custom-scm
module Capistrano
  class ArtifactPlugin < ::Capistrano::SCM::Plugin

    def set_defaults
      # Define any variables needed to configure the plugin.
      # set_if_empty :myvar, "my-default-value"
    end

    def define_tasks # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      namespace :artifact do
        desc 'Copy repo to releases'
        task :create_release do
          on release_roles(:all) do
            archive = fetch(:artifact_file, 'dist/raar.tar.gz')
            compression = fetch(:artifact_compression, 'gz')
            tar_option =
              case compression
              when 'gz' then 'z'
              when 'xz' then 'J'
              end

            file = "raar-#{fetch(:current_revision, 'CUSTOM')}.tar.#{compression}"
            folder = '/tmp/raar-build'
            path = "#{folder}/#{file}"

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
    end

    def register_hooks
      # Tell Capistrano to run the custom create_release task during deploy.
      after 'deploy:new_release_path', 'artifact:create_release'
      before 'deploy:set_current_revision', 'artifact:set_current_revision'
    end
  end
end
