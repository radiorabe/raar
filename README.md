# RAAR Radio Archive

[![Build Status](https://github.com/radiorabe/raar/actions/workflows/build.yml/badge.svg)](https://github.com/radiorabe/raar/actions/workflows/build.yml)
[![Code Climate](https://codeclimate.com/github/radiorabe/raar/badges/gpa.svg)](https://codeclimate.com/github/radiorabe/raar)
[![Coverage Status](https://coveralls.io/repos/github/radiorabe/raar/badge.svg?branch=master)](https://coveralls.io/github/radiorabe/raar?branch=master)

RAAR is a ruby application to manage and browse an audio archive.

It consists of three main parts:

* The importer adds existing audio recordings and their metadata to the archive.
* The downgrader reduces the audio quality of archived files after defined periods of time.
* A REST API gives access to the archived audio, the metadata and the archive configuration.

## Digging deeper

* [Architecture](doc/architecture.md)
* [Development](doc/development.md)
* [Deployment](doc/deployment.md)
* [API](doc/api.md)
* [Import](doc/import.md)
* [Downgrade](doc/downgrade.md)
* [Recording](doc/recording.md)

## License

RAAR is released under the terms of the GNU Affero General Public License.
Copyright 2015-2021 Radio Rabe.
See `LICENSE` for further information.
