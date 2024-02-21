# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).

Rake.application['db:fixtures:load'].invoke

unless Rails.root.join('db', 'airtime_development.sqlite3').exist?
  system 'sqlite3 db/airtime_development.sqlite3 < db/seeds/airtime_dump.sql'
end

require Rails.root.join('db', 'seeds', 'broadcast_seeder')
BroadcastSeeder.new.run
