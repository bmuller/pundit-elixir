# Changelog for v1.x

## Unreleased

### Fixed

  * Fix module detection during code reload (#6)

## v1.1.1 (2026-01-19)

### Enhancements

  * Fixed CI link in docs homepage / README
  * Included dialyxir in the test environment and ci.test mix task

## v1.1.0 (2025-06-27)

### Deprecations

  * Removed support for Elixir before version 1.15

## v1.0.2 (2023-02-09)

### Enhancements

  * Fixed issue with potentially uncompiled module when using scope/2 (#2)

## v1.0.1 (2022-04-07)

### Deprecations

  * Removed support for Elixir 1.8, moved from `Mix.Config` to `Config` usage

## v1.0.0 (2020-02-01)

### Enhancements

  * Update code to handle Elixir v1.10.0 changes (notably, the removal of `Code.ensure_compiled?`)
