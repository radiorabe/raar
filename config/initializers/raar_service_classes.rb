# Define default classes.
AudioProcessor.klass ||= AudioProcessor::Ffmpeg
Import::BroadcastMapping::Builder.klass ||= Import::BroadcastMapping::Builder::AirtimeDb
