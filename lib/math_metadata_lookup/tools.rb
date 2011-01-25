# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

require 'unicode'

module MathMetadata

  class << self

    def levenshtein_distance( s1, s2 )
      return 1.0 if s1 == s2

      s1u, s2u = s1.split(//u), s2.split(//u)
      tab = Array.new(s1u.size+1){ Array.new(s2u.size+1){0} }

      (0..s1u.size).each do |i|
        tab[i][0] = i
      end
      (0..s2u.size).each do |j|
        tab[0][j] = j
      end

      (1..s2u.size).each do |j|
        (1..s1u.size).each do |i|
          if s2u[j-1] == s1u[i-1]
            tab[i][j] = tab[i-1][j-1]
          else
            tab[i][j] = [
              tab[i-1][j] + 1,
              tab[i][j-1] + 1,
              tab[i-1][j-1] + 1
            ].sort.first
          end
        end
      end
      1 - (tab.last.last.to_f / ([s1u.size, s2u.size].sort.last))
    end # levenshtein_distance


    def normalize_range( range )
      range.to_s.gsub(/–|--/,'-')
    end


    def normalize_mscs( mscs )
      mscs.map{|m| m.split(/,|;/) }.flatten.map{|m| m =~ /\s*\(?([^\s\)\(]+)\)?\s*/; $1}
    end


    def normalize_name( name )
      # only latin chars
      trans = latex_to_utf8(name.to_s)
      trans = I18n.transliterate(trans)

      # remove Jr. 
      trans.sub! %r{\bjr\.(\b|$)}i, ' '

      # remove abbr.: Rakosnik, J. => Rakosnik, 
      trans.sub! %r{(\W|^)\w\.}i, ' '
  
      # transform: Surname, N.M. => Surname, N. M.
      trans.gsub( /([^\s,])?\.([^\s,])/, '\1. \2' )

      #MathMetadata.remove_punctuation(trans)
      trans
    end


    def remove_punctuation( s )
      str = s.gsub %r{(\w)[.,]+( |$)}i, '\1 '
      str.gsub! %r{(\s)[.,]+( |$)}i, '\1 '
      str.strip
    end


    def normalize_text( s )
      str = latex_to_utf8(s)
      str = I18n.transliterate(str).downcase
      str = remove_punctuation(str)
      str.gsub!(%r{\W+}, ' ')
      str.gsub!(%r{(?:the|a|of|)\s+}i, ' ')
      str.strip
    end

    ACCENT_REPL = {
      "`" => "\u0300", # grave accent
      "'" => "\u0301", # acute accent
      "^" => "\u0302", # circumflex
      '"' => "\u0308", # umlaut or dieresis
      "~" => "\u0303", # tilde
      "H" => "\u030b", # long Hungarian umlaut (double acute)
      "c" => "\u0327", # cedilla
      "=" => "\u0304", # macron accent
      "." => "\u0307", # dot over the letter
      "r" => "\u030a", # ring over the letter
      "u" => "\u0306", # breve over the letter
      "v" => "\u030c"  # caron/hacek ("v") over the letter
    }
    
    def latex_to_utf8( s )
      str = s.gsub( /\\(.)(?:([a-zA-Z])|{([a-zA-Z])}|{\\([a-zA-Z])})/ ) do |match|
        accent = ACCENT_REPL[$1]
        char = $2 || $3 || $4
        accent ? Unicode.normalize_KC( char + accent ) : match
      end
    end
 
  end # <<self

end # module
