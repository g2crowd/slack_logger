require_relative 'lib/slack_logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'slack_logger'
  spec.version       = SlackLogger::VERSION
  spec.authors       = ['Shawn Wheeler', 'Hamed Asghari']
  spec.email         = ['swheeler@g2.com']

  spec.summary       = 'A gem to send errors to Slack'
  spec.homepage      = 'https://www.g2.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/g2crowd/slack_logger'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'slack-ruby-client', '>= 0.14', '< 1.0'
end
