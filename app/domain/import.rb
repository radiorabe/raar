module Import

  # rubocop:disable Lint/RescueException
  # make sure we get notified in absolutely all cases.

  def self.run
    recordings = Recording::Finder.new.pending
    mappings = BroadcastMapping::Builder.new(recordings).run
    mappings.each { |b| Importer.new(b).run }
    Recording::Cleaner.new.run
  rescue Exception => e
    ExceptionNotifier.notify_exception(e)
  end

end
