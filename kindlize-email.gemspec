require_relative 'lib/kindlize-email/version'

Gem::Specification.new do |spec|
  spec.name          = 'kindlize-email'
  spec.version       = KindlizeEmail::VERSION
  spec.authors       = ['Jack Loughran']
  spec.email         = ['30052269+jackloughran@users.noreply.github.com']

  spec.summary       = 'convert .eml files to .mobi files suitable for sending to your kindle'
  spec.homepage      = 'https://github.com/jackloughran/kindlize-email'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jackloughran/kindlize-email'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'mail'
  spec.add_dependency 'down'
end
