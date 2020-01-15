# frozen_string_literal: true

namespace :erd do
  task :options => :customize
  task :customize do
    FileUtils.mkdir_p(Rails.root.join('doc'))
    ENV['attributes']  ||= 'content,inheritance,foreign_keys,timestamps'
    ENV['indirect']    ||= 'false'
    ENV['orientation'] ||= 'vertical'
    ENV['notation']    ||= 'uml'
    ENV['filename']    ||= 'doc/models'
    ENV['filetype']    ||= 'png'
    ENV['exclude']     ||= 'ActiveRecord::InternalMetadata,ActiveRecord::SchemaMigration,' \
                           'Airtime::Show,Airtime::ShowInstance,User'
  end
end
