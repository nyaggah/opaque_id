# Product Requirements Document: Publishing & Release Automation

## Introduction/Overview

This PRD outlines the implementation of a fully automated publishing and release system for the OpaqueId Ruby gem. The system will automatically version, test, and publish releases to RubyGems.org based on conventional commits, eliminating manual release processes and ensuring consistent, professional releases.

**Problem**: Manual release processes are error-prone, time-consuming, and inconsistent. Without automated versioning and publishing, releases can be delayed, version numbers can be inconsistent, and changelogs can be incomplete.

**Goal**: Implement a fully automated CI/CD pipeline that handles versioning, testing, changelog generation, and publishing based on conventional commits and the state of the main branch.

## Goals

1. **Automated Versioning**: Automatically determine version bumps (patch/minor/major) based on conventional commit types
2. **Automated Publishing**: Automatically publish to RubyGems.org when changes are ready
3. **Quality Gates**: Ensure all tests pass, code quality standards are met, and security checks pass before release
4. **Automated Changelog**: Generate changelog entries from conventional commits
5. **Dependency Management**: Automatically check for and update dependencies weekly
6. **Commit Standardization**: Enforce conventional commit format for consistent messaging
7. **Security**: Use RubyGems trusted publishing for secure, keyless releases

## User Stories

### As a Developer

- **US1**: I want my commits to automatically trigger appropriate version bumps so that I don't have to manually manage version numbers
- **US2**: I want releases to be published automatically when I push to main so that I don't have to remember to manually publish
- **US3**: I want commit message validation so that I follow consistent formatting standards
- **US4**: I want automated dependency updates so that my gem stays secure and up-to-date

### As a Maintainer

- **US5**: I want automated testing and quality checks before release so that I can trust the published code
- **US6**: I want automated changelog generation so that users know what changed in each release
- **US7**: I want security scanning before release so that vulnerabilities are caught early

### As a User

- **US8**: I want consistent, predictable releases so that I can trust the gem's stability
- **US9**: I want clear changelogs so that I understand what changed between versions

## Functional Requirements

### 1. Conventional Commits Integration

1.1. **Commit Message Validation**: Enforce conventional commit format (feat:, fix:, docs:, etc.) on all commits
1.2. **Commit Linting**: Use commitlint or similar tool to validate commit message format
1.3. **Pre-commit Hooks**: Automatically validate commit messages before they are accepted
1.4. **Commit Types**: Support standard types: feat, fix, docs, style, refactor, perf, test, chore, ci, build

### 2. Automated Versioning

2.1. **Semantic Versioning**: Use semantic versioning (MAJOR.MINOR.PATCH) based on conventional commits
2.2. **Version Bump Logic**:

- `feat:` commits → MINOR version bump
- `fix:` commits → PATCH version bump
- `BREAKING CHANGE:` or `!` → MAJOR version bump
- Other types → no version bump
  2.3. **Version Detection**: Automatically detect when version should be bumped based on unreleased commits
  2.4. **Version File Update**: Automatically update `lib/opaque_id/version.rb` with new version

### 3. GitHub Actions Workflow

3.1. **Single Workflow**: Update existing `main.yml` to include release automation
3.2. **Trigger Conditions**: Run on push to main branch when unreleased changes exist
3.3. **Workflow Steps**:

- Checkout code
- Setup Ruby environment
- Install dependencies
- Run tests
- Run RuboCop
- Security audit
- Determine version bump
- Update version file
- Generate changelog
- Create git tag
- Publish to RubyGems.org
- Create GitHub release

### 4. Quality Gates

4.1. **Test Execution**: Run full test suite before any release
4.2. **Code Quality**: Run RuboCop and fail if violations exist
4.3. **Security Scanning**: Run `bundle audit` to check for vulnerable dependencies
4.4. **Dependency Check**: Ensure all dependencies are up-to-date and secure

### 5. Changelog Generation

5.1. **Automated Generation**: Generate changelog from conventional commits since last release
5.2. **Changelog Format**: Use conventional changelog format with categorized sections
5.3. **Changelog Sections**: Features, Bug Fixes, Breaking Changes, Documentation, etc.
5.4. **Changelog Update**: Automatically update `CHANGELOG.md` with new entries

### 6. RubyGems Publishing

6.1. **Trusted Publishing**: Use RubyGems trusted publishing (no API keys required)
6.2. **MFA Enforcement**: Ensure MFA is required for publishing (already configured)
6.3. **Build Process**: Build gem package before publishing
6.4. **Publish Process**: Automatically push to RubyGems.org when all checks pass

### 7. Dependabot Integration

7.1. **Weekly Updates**: Check for dependency updates every Monday at 9 AM
7.2. **Update Types**: Check for both direct and indirect dependency updates
7.3. **Security Updates**: Prioritize security-related updates
7.4. **Update Strategy**: Create pull requests for dependency updates

### 8. Git Tag Management

8.1. **Automatic Tagging**: Create git tags for each release (e.g., `v1.2.3`)
8.2. **Tag Format**: Use semantic versioning format with `v` prefix
8.3. **Tag Push**: Automatically push tags to GitHub repository
8.4. **GitHub Release**: Create GitHub release with changelog and tag

## Non-Goals (Out of Scope)

1. **Manual Release Override**: No manual release triggers or overrides
2. **Multiple Branch Support**: Only support releases from main branch
3. **Pre-release Versions**: No support for alpha/beta/rc versions initially
4. **Monorepo Support**: Single gem repository only
5. **Custom Versioning Logic**: No custom versioning rules beyond conventional commits
6. **Rollback Automation**: No automatic rollback of failed releases

## Technical Considerations

### Dependencies

- **Release Please**: Google's tool for PR-based versioning and changelog generation
- **Bundler's release tasks**: Built-in rake tasks for building and tagging (already present)
- **commitlint**: For commit message validation (optional)
- **bundle-audit**: For security scanning

### GitHub Actions

- **googleapis/release-please-action**: For creating release PRs and versioning
- **rubygems/release-gem**: For RubyGems publishing with trusted publishing
- **actions/checkout**: For code checkout
- **ruby/setup-ruby**: For Ruby environment setup

### Configuration Files

- **release-please-config.json**: Release Please configuration
- **dependabot.yml**: Dependency update configuration
- **.github/workflows/release-please.yml**: Release PR workflow
- **.github/workflows/publish.yml**: Publishing workflow

### RubyGems Trusted Publishing

- Configure trusted publishing on RubyGems.org
- Use GitHub OIDC for authentication
- No API keys or secrets required

## Success Metrics

1. **Release Automation**: 100% of releases are automated (no manual intervention)
2. **Release Frequency**: Ability to release multiple times per day if needed
3. **Quality Gates**: 0% of releases with failing tests or security issues
4. **Commit Compliance**: 100% of commits follow conventional commit format
5. **Dependency Currency**: Dependencies updated within 7 days of availability
6. **Release Time**: From commit to published gem in under 10 minutes

## Open Questions

1. **Commit Message Enforcement**: Should we use pre-commit hooks or GitHub Actions validation?
2. **Changelog Format**: Should we use conventional-changelog or custom format?
3. **Version Bump Strategy**: Should we batch multiple commits into single releases?
4. **Rollback Strategy**: How should we handle failed releases or rollbacks?
5. **Notification Strategy**: Should we notify maintainers of successful/failed releases?
6. **Branch Protection**: Should we require status checks before merging to main?

## Implementation Priority

### Phase 1: Core Automation

- Conventional commits validation
- Automated versioning
- Basic GitHub Actions workflow
- RubyGems publishing

### Phase 2: Quality & Security

- Quality gates (tests, RuboCop, security)
- Automated changelog generation
- Dependabot integration

### Phase 3: Polish & Monitoring

- Enhanced notifications
- Release monitoring
- Performance optimization

## Acceptance Criteria

- [ ] All commits follow conventional commit format
- [ ] Version numbers are automatically bumped based on commit types
- [ ] Releases are automatically published to RubyGems.org
- [ ] Changelog is automatically generated from commits
- [ ] All tests pass before release
- [ ] RuboCop passes before release
- [ ] Security audit passes before release
- [ ] Dependencies are automatically updated weekly
- [ ] Git tags are automatically created for releases
- [ ] GitHub releases are automatically created
- [ ] RubyGems trusted publishing is configured
- [ ] No manual intervention required for releases
