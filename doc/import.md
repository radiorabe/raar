# RAAR Import

The importer takes care of adding recorded audio files into the archive database.
It's main executable lives in `bin/import` and may be called by a cron job:

    bash -l -c '$RAAR_HOME/bin/import >> /dev/null 2>&1'

## Procedure

The following steps are performed during the import process. The respective Classes/Methods are given in parentheses. See [Configuration](configuration.md) for details on the import/archive format settings.

1. The import is started (`Import.run`).
1. Find all recordings in the `IMPORT_DIRECTORIES` (`Import::Recording::Finder#pending`). Multiple directories may contain different recordings for the same times (for failover purposes). Recording durations do not have to correspond to broadcast durations.
1. Based on the timestamps given in the recording file names, map the recordings to their respective broadcasts (`Import::BroadcastMapping::Builder#run`). Different strategies would be possible, currently, this data is fetched directly for an Airtime database (`Import::BroadcastMapping::Builder::AirtimeDb`).
1. For each broadcast mapping, do the following (`Import::Importer#run`):
1. If the recordings do not cover the entire broadcast duration, cancel and retry later.
1. Select the best recording for a given time (`Import::Recording::Chooser#best`).
1. If the recording duration does not match the broadcast duration, cut the audio file(s) accordingly to get one single master file for the broadcast (`Import::Recording::Composer#compose`).
1. Transcode the master file into the defined archive formats in the `ARCHIVE_HOME` directory and create the corresponding database entries (`Import::Archiver#run`).
1. Mark the used recordings as imported (`Import::Recording#mark_imported`).
1. Delete all old imported recordings as configured by `DAYS_TO_KEEP_IMPORTED` and warn about unimported recordings, via `DAYS_TO_FINISH_IMPORT` (`Import::Recording::Cleaner#run`).
