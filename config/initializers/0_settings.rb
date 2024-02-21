# frozen_string_literal: true

# Load settings for the current environment from config/settings.yml
# and store them as object in Rails.applications.settings

file = Rails.root.join('config', 'settings.yml')
hash = YAML.safe_load(ERB.new(File.read(file)).result, aliases: true)
settings = hash.fetch(Rails.env).symbolize_keys

Rails.application.settings = Struct.new(*settings.keys).new(*settings.values)
