# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

dir = File.expand_path(File.dirname(__FILE__))
$:.unshift(dir) unless $:.include?(dir)

# toolset
require 'math_metadata_lookup/tools'

# abstract class for sites
require 'math_metadata_lookup/site'

# load up sites definition
Dir["#{dir}/math_metadata_lookup/sites/*.rb"].each do |site|
  require site
end

# main class
require 'math_metadata_lookup/lookup'
