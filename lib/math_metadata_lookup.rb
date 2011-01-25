# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

dir = File.expand_path(File.dirname(__FILE__))
$:.unshift(dir) unless $:.include?(dir)

# tools
require 'math_metadata_lookup/tools'

# result class
require 'math_metadata_lookup/result'

# entities
require 'math_metadata_lookup/entity'
require 'math_metadata_lookup/article'
require 'math_metadata_lookup/author'
require 'math_metadata_lookup/reference'

# abstract class for sites
require 'math_metadata_lookup/site'

# load up sites definition
Dir["#{dir}/math_metadata_lookup/sites/*.rb"].each do |site|
  require site
end

# main class
require 'math_metadata_lookup/lookup'
