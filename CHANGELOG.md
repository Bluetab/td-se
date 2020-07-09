# Changelog

## [4.0.1] 2020-07-09

### Fixed

- [TD-2815] Confidential filter was using old mappings producing empty results in concepts search

## [4.0.0] 2020-07-01

### Changed

- Update to Phoenix 1.5

## [3.20.0] 2020-04-20

### Changed

- [TD-2508] Update to Elixir 1.10

## [3.13.0] 2020-01-13

## Changed

- [TD-2271] Filter deleted structures on search

## [3.8.0] 2019-10-14

## Changed

- [TD-1721] Use aliases instead of indexes on search query

## [3.6.0] 2019-09-16

## Changed

- Use td-cache 3.5.1

## [3.2.0] 2019-07-24

## Changed

- [TD-2002] Update td-cache and delete permissions list from config

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
