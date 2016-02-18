# RAAR Downgrade

To free up some disk space in the archive, old audio files may be configured to be downgraded after a certain period of time.

This executable lives in `bin/downgrade` and may be called by a cron job:

    bash -l -c '$RAAR_HOME/bin/downgrade >> /dev/null 2>&1'

See [Architecture](architecture.md) for details on the downgrade settings.
