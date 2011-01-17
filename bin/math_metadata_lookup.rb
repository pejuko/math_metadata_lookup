#!/usr/bin/env ruby
# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

$KCODE="UTF8" if RUBY_VERSION < "1.9"

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

def print_help
  print $0
  puts " <article|author> -t <title> -a <author> -i <id> -s <mrev|zbl> -f <text|xml|html|ruby|yaml>"
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
  ["--format", "-f", GetoptLong::REQUIRED_ARGUMENT],
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

result = case $command
when 'article'
  l.article $options[:id], $options[:title].to_s, $options[:authors], $options[:format]
when 'author'
  l.author_name_forms $options[:authors].first, $options[:format]
else
  print_help
end

case $options[:format]
when :ruby
  pp result
when :yaml
  puts result.to_yaml
else
  result.each do |site|
    next unless site[:result]
    puts "Site: #{site[:name]}"
    puts site[:result]
    puts ""
  end
end
