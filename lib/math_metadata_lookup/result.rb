# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

module MathMetadata

  class Result
    include Enumerable

    FORMATS = [:ruby, :yaml, :xml, :html, :text]

    def initialize( meta=[] )
      @metadata = meta
    end


    def <<(val)
      @metadata << val
    end


    def each
      @metadata.each do |site|
        yield site
      end
    end


    def format( f=:ruby )
      self.send "to_#{f}"
    end


    def to_html
      result = ""
      @metadata.each do |site|
        next unless site[:result]
        result << %~
<div class="site">
    <h3>Site: #{site[:name]}</h3>~
        site[:result].to_a.each do |entity|
          result << entity.to_html
        end
        result << %~</div>~
      end
      result
    end


    def to_xml
      result = ""

      result << %~<?xml version="1.0" encoding="utf-8"?>
<mml>~
      @metadata.each do |site|
        next unless site[:result]
        result << %~
    <site name="#{site[:name]}">~
        site[:result].each do |entity|
          result << entity.to_xml
        end
        result << %~
    </site>
~
      end
      result << %~</mml>~

      result
    end


    def to_yaml
      @metadata.to_yaml
    end


    def to_array
      @metadata
    end


    def to_text
      result = ""
      @metadata.each do |site|
        next unless site[:result]
        result << "Site: #{site[:name]}\n"
        result << "URL: #{site[:url]}\n"
        result << "\n"
        site[:result].each do |entity|
          result << entity.to_text
        end
        result << "\n"
      end
      result
    end
    alias :to_str :to_text

  end

end # MathMetadata
