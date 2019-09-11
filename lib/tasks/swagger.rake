namespace :swagger do
  desc 'Generates the swagger.json into doc folder.'
  task :json => :environment do
    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.host = 'localhost'
    session.get('/')
    json = JSON.parse(session.response.body)
    File.write(Rails.root.join('doc', 'swagger.json'), JSON.pretty_generate(json))
    puts 'Generated doc/swagger.json'
  end
end
