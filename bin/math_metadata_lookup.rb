#!/usr/bin/env ruby
# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

$KCODE="UTF8" if RUBY_VERSION < "1.9"

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

def print_help
  puts ""
  puts "#{$0} <article|author> -t <title> -a <author> -i <id> -s <mrev|zbl> -f <text|html|ruby|yaml>"
  puts ""
  puts "Examples:"
  puts %~#{$0} article -t "Sobolev embeddings with variable exponent. II"~
  puts %~#{$0} article -t "Sobolev embeddings" -a "Rakosnik, Jiri" -a "Edmunds, David" -f html~
  puts %~#{$0} author -a "Vesely, Jiri"~
end

require 'pp'
require 'yaml'
require 'rubygems'
require 'math_metadata_lookup'

$command = ARGV.shift
unless $command
  print_help
  exit 1
end

require 'getoptlong'
opts = GetoptLong.new(
  ["--title", "-t", GetoptLong::REQUIRED_ARGUMENT],
  ["--author", "-a", GetoptLong::REQUIRED_ARGUMENT],
  ["--id", "-i", GetoptLong::REQUIRED_ARGUMENT],
  ["--site", "-s", GetoptLong::REQUIRED_ARGUMENT],
  ["--verbose", "-v", GetoptLong::NO_ARGUMENT],
  ["--format", "-f", GetoptLong::REQUIRED_ARGUMENT]
)

$options = {:sites => [], :authors => [], :format => :text, :verbose => false}
opts.each do |opt, val|
  optkey = opt[2..-1].to_sym
  case optkey
  when :title, :id
    $options[optkey] = val.strip
  when :site, :author
    $options["#{optkey}s".to_sym] << val.strip
  when :format
    $options[optkey] = val.strip.to_sym
  when :verbose
    $options[optkey] = true
  end
end

pp $options if $options[:verbose]

sites = $options[:sites].size == 0 ? :all : $options[:sites].map{|s| s.to_sym}
l = MathMetadata::Lookup.new :sites => sites, :verbose => $options[:verbose]

args = $options.dup
args[:format] = $options[:format] == :yaml ? :ruby : $options[:format]
result = case $command
when 'article'
  l.article args
when 'author'
  l.author_name_forms :name => $options[:authors].first, :format => args[:format]
else
  print_help
end

case $options[:format]
when :ruby
  pp result
when :yaml
  puts result.to_yaml
when :html
  result.each do |site|
    puts %~
<div class="site">
    <h3>Site: #{site[:name]}</h3>
    #{site[:result]}
</div>~
  end
else
  result.each do |site|
    next unless site[:result]
    puts "Site: #{site[:name]}"
    puts site[:result]
    puts ""
  end
end
