namespace :erd do
  task :options => :customize
  task :customize do
    #require Rails.root.join('lib', 'tasks', 'rails_erd_patch.rb')
    FileUtils.mkdir_p(Rails.root.join('doc'))
    ENV['attributes']  ||= 'content,inheritance,foreign_keys,timestamps'
    ENV['indirect']    ||= 'false'
    ENV['orientation'] ||= 'vertical'
    ENV['notation']    ||= 'uml'
    ENV['filename']    ||= 'doc/models'
    ENV['filetype']    ||= 'png'
  end
end
