# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2
# 
# @author: Petr Kovar <pejuko@gmail.com>

require 'rubygems'
require 'find'

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Search mathematical reviews sites and fetches metadata about articles."
  s.homepage = "http://github.com/pejuko/math_metadata_lookup"
  s.email = "pejuko@gmail.com"
  s.authors = ["Petr Kovar"]
  s.name = 'math_metadata_lookup'
  s.version = '0.1.4'
  s.date = Time.now.strftime("%Y-%m-%d")
  s.add_dependency('unicode')
  s.add_dependency('unidecoder')
  s.add_dependency('ya2yaml')
  s.require_path = 'lib'
  s.files = ["bin/math_metadata_lookup", "README.md", "math_metadata_lookup.gemspec", "TODO", "Rakefile"]
  s.files += Dir["lib/**/*.rb", "resources/*"]
  s.executables = ["math_metadata_lookup"]
  s.description = <<EOF
This utility/library search mathematical reviews sites and fetches metadata about articles.
It can return results as one of text, xml, html, yaml or ruby formats.
EOF
end

