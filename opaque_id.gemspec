# frozen_string_literal: true

require_relative 'lib/opaque_id/version'

Gem::Specification.new do |spec|
  spec.name = 'opaque_id'
  spec.version = OpaqueId::VERSION
  spec.authors = ['Joe Nyaggah']

  spec.summary = 'Generate cryptographically secure, collision-free opaque IDs for ActiveRecord models'
  spec.description = <<~DESC
    OpaqueId provides a simple way to generate unique, URL-friendly identifiers for your ActiveRecord models.
    Uses rejection sampling for unbiased random generation, ensuring perfect uniformity across the alphabet.
    Prevents exposing incremental database IDs in URLs and APIs.
  DESC
  spec.homepage = 'https://github.com/nyaggah/opaque_id'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/nyaggah/opaque_id'
  spec.metadata['changelog_uri'] = 'https://github.com/nyaggah/opaque_id/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile docs/ .cursor/]) ||
        (f.match?(/\.(md|yml|yaml|json)$/) && !f.start_with?('lib/'))
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'activerecord', '>= 8.0'
  spec.add_dependency 'activesupport', '>= 8.0'

  # Development dependencies
  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'rails', '>= 8.0'
  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'rubocop', '~> 1.81'
  spec.add_development_dependency 'sqlite3', '>= 2.1'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
