# frozen_string_literal: true

module Import

  def self.run
    recordings = Recording::Finder.new.pending
    mappings = BroadcastMapping::Builder.new(recordings).run
    mappings.each { |b| Importer.new(b).run }
    Recording::Cleaner.new.run
  rescue Exception => e # rubocop:disable Lint/RescueException
    # make sure we get notified in absolutely all cases.
    Rails.logger.error("FATAL #{e}\n  #{e.backtrace.join("\n  ")}")
  end

end
