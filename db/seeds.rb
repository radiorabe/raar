# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

Rake.application['db:fixtures:load'].invoke

system 'sqlite3 db/airtime_development.sqlite3 < db/seeds/airtime_dump.sql'

require Rails.root.join('db', 'seeds', 'broadcast_seeder')
BroadcastSeeder.new.run
