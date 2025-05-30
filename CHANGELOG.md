# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-01-27

### Added
- Modern GitHub Actions CI/CD pipeline replacing Travis CI
- Comprehensive documentation with usage examples
- Support for latest Elixir versions (1.14-1.17)
- Enhanced README with Reddit-style examples and Phoenix LiveView integration

### Changed
- **BREAKING**: Updated minimum Elixir version to 1.14+
- Updated all dependencies to latest versions:
  - `floki` ~> 0.37 (was ~> 0.20)
  - `tesla` ~> 1.14 (was ~> 1.2)
  - `finch` ~> 0.19 (new HTTP client replacing httpoison)
  - `excoveralls` ~> 0.18 (was ~> 0.10)
  - `ex_doc` ~> 0.38 (was ~> 0.19)
- Replaced deprecated `tempfile` with modern `temp` package
- Updated config files to use modern `Config` module instead of `Mix.Config`
- Repository moved to https://github.com/iNeedThis/link_preview

### Fixed
- Fixed tempfile dependency compilation issues
- Improved error handling and robustness
- Updated deprecated function calls

### Security
- Updated all dependencies to address security vulnerabilities
- Added dependency security audit to CI pipeline

## [1.0.0] - 2019-12-11

### Added
- Initial stable release
- Support for Open Graph meta tags
- Support for Twitter Card meta tags
- Support for HTML meta tags and elements
- Image filtering with Mogrify integration
- Basic parsing strategies
- Comprehensive test suite

### Features
- Extract page titles from `<title>` tags
- Extract descriptions from meta tags and header elements
- Extract images from `<img>` tags and meta properties
- Support for relative URL resolution
- Optional image size filtering
- Configurable string processing

[1.1.0]: https://github.com/iNeedThis/link_preview/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/iNeedThis/link_preview/releases/tag/v1.0.0
