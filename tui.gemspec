# frozen_string_literal: true

Gem::Specification.new { |spec|
  spec.name                  = 'text-ui'
  spec.version               = '0.2.0'
  spec.authors               = ['Skorobogaty Dmitry']
  spec.email                 = ['skorobogaty.dmitry@gmail.com']
  spec.license               = 'LGPL-3.0-only'
  spec.summary               = 'Draw nested boxes in console.'
  spec.description           = File.read('README.md')[/(?<=# Description)[^#]+/].chomp
  spec.homepage              = 'https://github.com/skorobogatydmitry/tui'
  spec.required_ruby_version = '>= 3.3'
  spec.files                 = Dir['lib/**/*.rb', 'README.md']

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => spec.homepage,
    'allowed_push_host' => 'https://rubygems.org/'
  }

  # keep in sync with Gemfile
  spec.add_dependency 'unicode-display_width'
}
