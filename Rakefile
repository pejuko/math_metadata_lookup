# -*- coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2
# 
# @author: Petr Kovar <pejuko@gmail.com>
$KCODE='UTF8'

require 'rake/gempackagetask'
require 'rake/clean'

CLEAN << "coverage" << "pkg" << "README.html" << "CHANGELOG.html" << '*.rbc' << "html/" << "yardoc/"

task :default => [:doc, :gem]

Rake::GemPackageTask.new(eval(File.read("math_metadata_lookup.gemspec"))) {|pkg|}


docs = []

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


  task :readme do |t|
    build_document("README.md")
  end

  docs << :readme

rescue LoadError
end


begin

  require 'rake/rdoctask'

  Rake::RDocTask.new do |rd|
    rd.main = "README.md"
    rd.rdoc_files.include("README.md", "lib/**/*.rb", "bin/*")
  end

  docs << :rdoc

rescue LoadError
end


begin

  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files    = ['README.md', 'lib/**/*.rb', 'bin/*']   # optional
    t.options  = ['--output-dir=yardoc'] # optional
  end

  docs << :yard

rescue LoadError
end

task :doc => docs
