# Changelog

## [Unreleased]

### Added

- [TD-1571] Elixir's Logger config will check for EX_LOGGER_FORMAT variable to override format

## [2.14.0] 2019-03-04

### Changed

- [TD-1485] Review and update service
    - Include on search the index `ingest`
    - Filter `business_concept` by `_confidential` field
    - Filtes `data_structure` by `confidential` field