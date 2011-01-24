# -*-: coding: utf-8 -*-
# vi: fenc=utf-8:expandtab:ts=2:sw=2:sts=2

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
      trans = I18n.transliterate( name.to_s )
  
      # vyresim: Surname, N.M. => Surname, N. M.
      # mrev to jinak nenajde
      trans.gsub( /([^\s,])?\.([^\s,])/, '\1. \2' )
    end
 
  end # <<self

end # module
