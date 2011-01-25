# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2
# 
# @author: Petr Kovar <pejuko@gmail.com>
$KCODE='UTF8'

require 'rake/gempackagetask'
require 'rake/clean'

CLEAN << "coverage" << "pkg" << "README.html" << "CHANGELOG.html" << '*.rbc'

task :default => [:doc, :gem]

Rake::GemPackageTask.new(eval(File.read("math_metadata_lookup.gemspec"))) {|pkg|}

begin
  require 'bluecloth'

  def build_document(mdfile)
    fname = $1 if mdfile =~ /(.*)\.md$/
    raise "Unknown file type" unless fname

    data = File.read(mdfile)
    md = Markdown.new(data)
    htmlfile = "#{fname}.html"

    File.open(htmlfile, "w") { |f| f << md.to_html }
  end

  task :doc => [:readme]

  task :readme do |t|
    build_document("README.md")
  end

rescue LoadError
end
