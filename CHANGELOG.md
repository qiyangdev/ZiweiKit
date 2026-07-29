# Changelog

All notable changes to ZiweiKit are documented in this file. The project uses
[Semantic Versioning](https://semver.org/).

## Unreleased

No unreleased changes.

## 0.1.0 - 2026-07-29

### Added

- Validation for custom mutagen and brightness tables.
- Structural validation when decoding generated chart and horoscope models.
- Explicit `1901...2099` calculation support contract.
- Full-range calendar round-trip and malformed-input tests.
- Continuous integration for the Swift package and iOS example.

### Changed

- Date strings now require exactly three numeric components.
- Initializers for generated chart and horoscope result models are internal;
  callers create these values through `Ziwei` and `Astrolabe` calculation APIs.

### Fixed

- Prevented malformed custom brightness tables from causing out-of-bounds access.

## Release process

Before creating a release tag:

1. Move the Unreleased entries into a versioned section with the release date.
2. Run `swift test` and build `ZiweiKitExample` for iOS Simulator.
3. Confirm the DocC workflow succeeds with warnings treated as errors.
4. Create an annotated semantic-version tag, for example `git tag -a 0.1.0 -m "ZiweiKit 0.1.0"`.
5. Push the commit and tag only after CI succeeds.
