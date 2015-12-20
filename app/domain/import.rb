module Import

  # rubocop:disable Lint/RescueException
  # make sure we get notified in absolutely all cases.

  def self.run
    recordings = Recording::Finder.pending
    mappings = BroadcastMapping::Builder.new(recordings).run
    mappings.each { |b| Importer.new(b).run }
    Recording::Cleaner.clear_old_imported
    Recording::Cleaner.warn_for_old_unimported
  rescue Exception => e
    ExceptionNotifier.notify_exception(e)
  end

end
