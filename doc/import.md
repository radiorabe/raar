# RAAR Import

The importer takes care of adding recorded audio files into the archive database.

See [Architecture](architecture.md) for details on the import settings.

## Recordings

The import processes audio files from a external sources, aka recordings. The way these files are created is not part of RAAR. The following pre-conditions must hold:

* The audio files are put in the directories defined by `IMPORT_DIRECTORIES`.
* Multiple directories may contain different recordings for the same times (for failover purposes), but with the same duration.
* Recording durations do not have to correspond to broadcast durations.
* The recording file names must be in the format `yyyy-mm-ddTHHMMSS±ZZZZ_ddd.*` (year '-' month '-' day 'T' hour minute second '+/-' time zone offset '_' duration '.' extension, e.g. '2015-02-12T120000+0200_060.mp3').

## Procedure

The following steps are performed during the import process. The respective Classes/Methods are given in parentheses.

1. The import is started (`Import.run`).
1. Find all recordings in the `IMPORT_DIRECTORIES` (`Import::Recording::Finder#pending`).
1. Based on the timestamps given in the recording file names, map the recordings to their respective broadcasts (`Import::BroadcastMapping::Builder#run`). Different strategies would be possible by implementing different `Import::BroadcastMapping::Builder`s. Currently, this data is fetched directly for an Airtime database (`Import::BroadcastMapping::Builder::AirtimeDb`). If no mappings are found but a `IMPORT_DEFAULT_SHOW_ID` is defined, broadcasts mappings for this show are created.
1. For each broadcast mapping, do the following (`Import::Importer#run`):
1. If the recordings do not cover the entire broadcast duration, cancel and retry later.
1. Select the best recording for a given time (`Import::Recording::Chooser#best`).
1. If the recording duration does not match the broadcast duration, cut the audio file(s) accordingly to get one single master file for the broadcast (`Import::Recording::Composer#compose`).
1. Transcode the master file into the defined archive formats in the `ARCHIVE_HOME` directory and create the corresponding database entries (`Import::Archiver#run`).
1. Mark the used recordings as imported (`Import::Recording#mark_imported`).
1. Delete all old imported recordings as configured by `DAYS_TO_KEEP_IMPORTED` and warn about unimported recordings, via `DAYS_TO_FINISH_IMPORT` (`Import::Recording::Cleaner#run`).

## Custom Import

It is also possible to run an import with custom classes given by environment variables. To import all MP3 recordings from a given directory that contain the date, time and show name in their filename (i.e. without hitting Airtime), run:

    BROADCAST_MAPPING_BUILDER=SelfContained \
    RECORDING_FILE=Mp3Rec \
    IMPORT_DIRECTORIES=/path/to/import \
    DAYS_TO_FINISH_IMPORT='' \
    DAYS_TO_KEEP_IMPORTED='' \
    bin/import

The show names from the file names may be mapped to real show names in `config/show_names.yml`.
