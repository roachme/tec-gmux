## [Unreleased]

### Added

- `gmux`: Add help message for gmux
- `gmux`: Add new command `update`
- `gmux`: Add new command `commit`
- `gmux`: Resolve each submodule's own default branch (auto-detected from its remote HEAD, overridable per-submodule via `modules` in config) instead of assuming the parent repo's default branch

### Changed

### Fixed

- `gmux`: Refactor class Repo
- `gmux`: Minor fixes
- `gmux`: Fix exit code
- `gmux`: Fix fresh repo clone
- `gmux`: Switch back to task branch after command `update`

### Deleted
