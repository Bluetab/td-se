# Changelog

## [7.7.0] 2025-06-30

### Added

- [TD-7299] Refactor gitlab-ci pipeline and add Trivy check

## [7.4.0] 2025-04-09

### Changed

- License and td-core

## [7.2.0] 2025-03-10

### Added

- [TD-7155] Introduce simple query string query for global search

## [7.0.0] 2025-01-13

### Changed

- [TD-6911]
  - update Elixir 1.18
  - update dependencies
  - update Docker RUNTIME_BASE=alpine:3.21
  - remove unused dependencies
  - remove swagger
- [TD-5713]
  - Search strategy for indexes that aligns with those used in their corresponding services.
  - Limit the search scope to the native fields of each index.

## [6.16.0] 2024-12-16

### Added

- [TD-6982] Added SSL and ApiKey configuration for Elasticsearch

## [6.13.0] 2024-10-15

### Changed

- [TD-6773] Update td-cache and td-core
- [TD-6617] Update td-core

## [6.9.2] 2024-07-29

### Added

- [TD-6734] Update td-core

## [6.9.1] 2024-07-26

### Added

- [TD-6733] Update td-core

## [6.9.0] 2024-07-26

### Changed

- [TD-6602], [TD-6723] Update td-cache and td-core

## [6.8.0] 2024-07-18

### Added

- [TD-6713] Update td-core

## [6.5.0] 2024-04-30

### Added

- [TD-6535] Update Td-core for Elasticsearch reindex improvements and fix index deletion by name

## [6.4.0] 2024-04-09

### Added

- [TD-6527] Add LICENSE file

### Fixed

- [TD-6401] Update td_core

## [6.3.0] 2024-03-18

### Added

- [TD-4110] Allow structure scoped permissions management

## [6.2.1] 2024-02-27

### Fixed

- [TD-6243] TdCore.Search.Guardian configuration

## [6.2.0] 2024-02-26

### Added

- [TD-6243]
  - Support for deleting Elasticsearch indexes
  - Refactor for Elixir 1.16 and use TdCore authentication

## [5.10.0] 2023-07-06

### Changed

- [TD-5787] Add multi_match param in elastic query for Boost option
- [TD-5912] `.gitlab-ci.yml` adaptations for develop and main branches

## [5.4.0] 2023-03-28

### Added

- [] Add whitesource file

## [4.56.0] 2022-11-28

### Added

- [TD-5289] Elasticsearch 7 compatibility

## [4.54.0] 2022-10-31

### Changed

- [TD-5284] Phoenix 1.6.x

## [4.52.0] 2022-10-03

### Added

- [TD-4903] Include `sobelow` static code analysis in CI pipeline

## [4.48.0] 2022-07-26

### Changed

- [TD-3614] Support for access token revocation

## [4.45.0] 2022-06-06

### Changed

- Updated dependencies

## [4.40.0] 2022-03-14

### Changed

- [TD-4491] Compatibility with new permissions model

## [4.25.0] 2021-07-26

### Changed

- Updated dependencies

## [4.22.0] 2021-06-15

### Fixed

- [TD-3786] User without permissions cannot use global search

## [4.21.0] 2021-05-31

### Changed

- [TD-3753] Build using Elixir 1.12 and Erlang/OTP 24

## [4.20.0] 2021-05-17

### Changed

- Security patches from `alpine:3.13`
- Update dependencies

## [4.19.0] 2021-05-04

### Added

- [TD-3628] Force release to update base image

## [4.15.0] 2021-03-08

### Changed

- [TD-3341] Build with `elixir:1.11.3-alpine`, runtime `alpine:3.13`

## [4.14.0] 2021-02-22

### Changed

- [TD-3265] Retrieve business concept id on search

## [4.13.0] 2021-02-08

### Added

- [TD-3263] Use HTTP Basic authentication for Elasticsearch if environment
  variables `ES_USERNAME` and `ES_PASSWORD` are present

### CHANGED

- Breaking change: New environment variable `ES_URL` replaces existing
  `ES_HOST`/`ES_PORT`

## [4.12.0] 2021-01-25

### Changed

- [TD-3163] Auth tokens now include `role` claim instead of `is_admin` flag
- [TD-3182] Allow to use redis with password

## [4.11.0] 2021-01-11

### Changed

- [TD-3170] Build docker image which runs with non-root user

## [4.8.0] 2020-11-16

### Changed

- [TD-2980] Add path to search results

## [4.0.1] 2020-07-09

### Fixed

- [TD-2815] Confidential filter was using old mappings producing empty results
  in concepts search

## [4.0.0] 2020-07-01

### Changed

- Update to Phoenix 1.5

## [3.20.0] 2020-04-20

### Changed

- [TD-2508] Update to Elixir 1.10

## [3.13.0] 2020-01-13

### Changed

- [TD-2271] Filter deleted structures on search

## [3.8.0] 2019-10-14

### Changed

- [TD-1721] Use aliases instead of indexes on search query

## [3.6.0] 2019-09-16

### Changed

- Use td-cache 3.5.1

## [3.2.0] 2019-07-24

### Changed

- [TD-2002] Update td-cache and delete permissions list from config

## [3.1.0] 2019-07-08

### Changed

- [TD-1681] Cache improvement (td-cache instead of td-perms)
- [TD-1942] Use Jason instead of Posion for JSON encoding/decoding

## [3.0.0] 2019-06-25

### Changed

- [TD-1893] Use CI_JOB_ID instead of CI_PIPELINE_ID

## [2.19.0] 2019-05-14

### Fixed

- [TD-1774] Newline is missing in logger format

## [2.16.0] 2019-04-01

### Added

- [TD-1571] Elixir's Logger config will check for EX_LOGGER_FORMAT variable to
  override format

## [2.14.0] 2019-03-04

### Changed

- [TD-1485] Review and update service
  - Include on search the index `ingest`
  - Filter `business_concept` by `_confidential` field
  - Filtes `data_structure` by `confidential` field
