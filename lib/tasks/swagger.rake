# frozen_string_literal: true

namespace :swagger do
  desc 'Generates the swagger.json into doc folder.'
  task :json => :environment do
    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.host = 'localhost'
    session.get('/')
    json = JSON.parse(session.response.body)
    Rails.root.join('doc', 'swagger.json').write(JSON.pretty_generate(json))
    puts 'Generated doc/swagger.json'
  end
end
