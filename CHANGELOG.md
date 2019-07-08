# Changelog

## [3.1.0] 2019-07-08

## Changed

- [TD-1681] Cache improvement (td-cache instead of td-perms)
- [TD-1942] Use Jason instead of Posion for JSON encoding/decoding

## [3.0.0] 2019-06-25

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