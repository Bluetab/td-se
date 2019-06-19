# Changelog

## [Unreleased] 2019-05-18

### Changed

- [TD-1893] Use CI_JOB_ID instead of CI_PIPELINE_ID

## [2.19.0] 2019-05-14

### Fixed

- [TD-1774] Newline is missing in logger format

## [2.16.0]

### Added

- [TD-1571] Elixir's Logger config will check for EX_LOGGER_FORMAT variable to override format

## [2.14.0] 2019-03-04

### Changed

- [TD-1485] Review and update service
    - Include on search the index `ingest`
    - Filter `business_concept` by `_confidential` field
    - Filtes `data_structure` by `confidential` field