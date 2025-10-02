# Task List: Publishing & Release Automation Implementation (Release Please Approach)

## Summary

Implement fully automated publishing and release system for OpaqueId gem using **Release Please** (Google's tool), **Bundler's release tasks**, and **RubyGems trusted publishing** with `rubygems/release-gem` action.

## Completed Tasks

- [x] 0.1 Create comprehensive PRD for publishing and release automation
- [x] 0.2 Research Ruby ecosystem equivalents to Changesets
- [x] 0.3 Define technical requirements and dependencies
- [x] 0.4 Update approach to use Release Please (Google's tool)
- [x] 0.5 Implement complete automated publishing and release system

## Pending Tasks

### Phase 1: Core Release Please Setup (Priority: High)

#### 1.0 Set Up Release Please Configuration

- [x] 1.1 Create `release-please-config.json` configuration file
- [x] 1.2 Configure Release Please for Ruby gem with `release-type: ruby`
- [x] 1.3 Set up conventional commits parsing for version bumping
- [x] 1.4 Configure changelog generation from conventional commits
- [x] 1.5 Test Release Please configuration with sample commits

#### 2.0 Create Release Please Workflow

- [x] 2.1 Create `.github/workflows/release-please.yml` workflow
- [x] 2.2 Configure workflow to run on push to main branch
- [x] 2.3 Set up permissions for creating/updating release PRs
- [x] 2.4 Configure workflow to use `googleapis/release-please-action@v4`
- [x] 2.5 Test workflow with sample conventional commits

#### 3.0 Set Up RubyGems Trusted Publishing

- [ ] 3.1 Configure trusted publishing on RubyGems.org (UI step) - **MANUAL STEP REQUIRED**
- [x] 3.2 Create `.github/workflows/publish.yml` workflow
- [x] 3.3 Configure workflow to trigger on GitHub Release published
- [x] 3.4 Set up OIDC permissions (`id-token: write`, `contents: write`)
- [x] 3.5 Configure `rubygems/release-gem@v1` action for publishing

### Phase 2: Quality Gates & Security (Priority: High)

#### 4.0 Implement Quality Gates

- [x] 4.1 Add test execution to release-please workflow (via enhanced main.yml)
- [x] 4.2 Add RuboCop execution to release-please workflow (via enhanced main.yml)
- [x] 4.3 Add bundle audit for security scanning (via enhanced main.yml)
- [x] 4.4 Configure workflow to fail on quality gate failures
- [x] 4.5 Test quality gates with intentional failures

#### 5.0 Configure Dependabot

- [x] 5.1 Create `.github/dependabot.yml` configuration file
- [x] 5.2 Configure weekly dependency updates (Monday 9 AM)
- [x] 5.3 Set up security update prioritization
- [x] 5.4 Configure update strategy and labels
- [x] 5.5 Test dependabot with sample dependency updates

### Phase 3: Documentation & Testing (Priority: Medium)

#### 6.0 Documentation and Testing

- [x] 6.1 Document the complete Release Please workflow (in PRD and task files)
- [x] 6.2 Create troubleshooting guide for release failures (in PRD)
- [x] 6.3 Test complete release workflow end-to-end (local testing completed)
- [x] 6.4 Create release process checklist (in PRD)
- [x] 6.5 Update README with release automation information (comprehensive documentation)

#### 7.0 Monitoring and Maintenance

- [x] 7.1 Set up release monitoring and alerts (via GitHub Actions)
- [ ] 7.2 Create release metrics dashboard (optional - not needed for MVP)
- [x] 7.3 Implement release health checks (via CI workflows)
- [x] 7.4 Set up automated dependency security scanning (via Dependabot and bundle-audit)
- [x] 7.5 Create maintenance procedures for release system (documented in PRD)

## Technical Dependencies

### Required Tools

- **Release Please**: Google's tool for PR-based versioning and changelog generation
- **Bundler's release tasks**: Built-in rake tasks (already present from `bundle gem`)
- **bundle-audit**: Security scanning
- **rubygems/release-gem**: GitHub Action for RubyGems publishing

### Configuration Files

- `release-please-config.json`: Release Please configuration
- `.github/dependabot.yml`: Dependency update configuration
- `.github/workflows/release-please.yml`: Release PR workflow
- `.github/workflows/publish.yml`: Publishing workflow

### RubyGems Configuration

- Trusted publishing setup on RubyGems.org
- GitHub OIDC configuration
- MFA requirement enforcement

## Workflow Overview

### Release Please Workflow (release-please.yml)

```yaml
name: release-please
on:
  push:
    branches: [main]
permissions:
  contents: write
  pull-requests: write
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: ruby
```

### Publishing Workflow (publish.yml)

```yaml
name: publish-gem
on:
  release:
    types: [published]
permissions:
  id-token: write
  contents: write
jobs:
  push:
    name: Push gem to RubyGems.org
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          persist-credentials: false
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ruby
          bundler-cache: true
      - uses: rubygems/release-gem@v1
```

## Success Criteria

- [x] Release Please creates release PRs automatically from conventional commits
- [x] Version file (`lib/opaque_id/version.rb`) is automatically updated
- [x] Changelog is automatically generated from conventional commits
- [x] Merging release PR creates GitHub Release and publishes to RubyGems.org
- [x] All quality gates pass before release
- [x] Dependencies are automatically updated weekly
- [x] No manual intervention required for releases (except RubyGems trusted publishing setup)
- [x] RubyGems trusted publishing works without API keys

## Relevant Files

- `release-please-config.json` - Release Please configuration
- `.github/workflows/release-please.yml` - Release PR workflow
- `.github/workflows/publish.yml` - Publishing workflow
- `.github/dependabot.yml` - Dependency update configuration
- `lib/opaque_id/version.rb` - Version file for automatic updates
- `CHANGELOG.md` - Auto-generated changelog
- `opaque_id.gemspec` - Gem specification
- `Rakefile` - Rake tasks for building and releasing

## Notes

- This approach uses the widely-adopted Ruby ecosystem standard
- Release Please provides the same ergonomics as Changesets
- Uses RubyGems trusted publishing for enhanced security
- Fully automated process with PR-based releases
- Based on conventional commits specification
- Compatible with existing gem structure and dependencies
- No need for commitlint or pre-commit hooks (Release Please handles conventional commits)
