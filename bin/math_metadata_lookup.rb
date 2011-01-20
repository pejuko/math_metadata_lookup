#!/usr/bin/env ruby
# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

$KCODE="UTF8" if RUBY_VERSION < "1.9"

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

def print_help
  puts ""
  puts "#{$0} <article|author> -t <title> -a <author> -i <id> -s <mrev|zbl> -f <text|html|xml|ruby|yaml>"
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
  ["--year", "-y", GetoptLong::REQUIRED_ARGUMENT],
  ["--id", "-i", GetoptLong::REQUIRED_ARGUMENT],
  ["--site", "-s", GetoptLong::REQUIRED_ARGUMENT],
  ["--verbose", "-v", GetoptLong::NO_ARGUMENT],
  ["--format", "-f", GetoptLong::REQUIRED_ARGUMENT]
)

$options = {:sites => [], :authors => [], :format => :text, :verbose => false}
opts.each do |opt, val|
  optkey = opt[2..-1].to_sym
  case optkey
  when :title, :id, :year
    $options[optkey] = val.strip
  when :site, :author
    $options["#{optkey}s".to_sym] << val.strip
  when :format
    $options[optkey] = val.strip.to_sym
  when :verbose
    $options[optkey] = true
  end
end

unless MathMetadata::Result::FORMATS.include?($options[:format].to_sym)
  print_help
  exit 1
end

pp $options if $options[:verbose]

sites = $options[:sites].size == 0 ? :all : $options[:sites].map{|s| s.to_sym}
l = MathMetadata::Lookup.new :sites => sites, :verbose => $options[:verbose]

args = $options.dup
args[:format] = $options[:format] == :yaml ? :ruby : $options[:format].to_sym
result = case $command
when 'article'
  l.article args
when 'author'
  l.author :name => $options[:authors].first, :format => args[:format]
else
  print_help
  exit 1
end

case $options[:format].to_sym
when :ruby
  pp result
when :yaml, :html, :xml, :text
  puts result.format($options[:format])
end
