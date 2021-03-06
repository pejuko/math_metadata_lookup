About
-----

This utility search mathematical reviews sites and fetches metadata about articles.
It returns results as one of text, xml, html, yaml, json or ruby formats.
It can work with LaTeX accent notation.

Supported sites
===============

* MathSciNet (mr)
* Zentralblatt (zbl)
* Numdam (numdam)
* Cedram (cedram)
* DmlCZ (dmlcz)
* Bulgarian DML (basbg)


Installation
------------

``math_metadata_lookup`` is written in Ruby. Consult your system documentation how to install ruby and rubygems,
then you can install ``math_metadata_lookup`` using rubygems:

    gem install math_metadata_lookup


Command line usage example
--------------------------

To get full help run it without any argument:

    math_metadata_lookup

Fetching metadata about an article:

    math_metadata_lookup.rb article -t "Sobolev embeddings with variable exponent. II"

Returns list of articles as html:

    bin/math_metadata_lookup.rb article -t "Sobolev embeddings" -a "Rakosnik" -a "Edmunds" -f html

Searching for authors:

    bin/math_metadata_lookup.rb author -a "Vesely, Jiri"


Usage from ruby
---------------

    require 'rubygems'
    require 'math_metadata_lookup'
    
    # initialize search engine to look only into Mathematical Reviews database
    l = MathMetadata::Lookup.new( :sites => [:mr], :verbose => false )
    
    # fetch first site from search result
    mr_result = l.article( :title => "Sobolev embeddings with variable exponent. II" ).first

    # get first article from the :mr site
    article = mr_result[:result].first
    
    # print out article authors separated with semicolon
    puts article[:authors].join("; ")


Resources
---------

Content of the resource directory:

* ``math_metadata_lookup.js``: contains function ``toggle_references( id )``. It can toggle visibility of references in html document. By default are all references visible. If you set in css class references attribute display to none it will be hidden by default.


Function reference for MathMetadata::Lookup class
-------------------------------------------------

#article( hash )

Hash arguments are:

* article id is known
  * **:id**      String

* article id is unknown 
  * **:title**   String
  * **:authors** Array of Strings
  * **:year**    String

Returns instance of class Result.


#author( hash )

Search for authors "name forms".

Hash arguments are:

* **:name** String. Author name.

Returns instance of class Result.


#heuristic( hash )

Returns only one best match from each site where similarity is higher then threshold.
It runs article search with first two words from title and only surnames from author names.
The result of search is sorted by similarity and articles with similarity less then threshold are deleted.
Similarity is count as weighted average from title, authors and year using Levenshtein distance method.
The Levenshtein distance function is run on full given title and full given names.

Hash arguments are:

* **:title**     String
* **:authors**   Array of Strings
* **:year**      String
* **:threshold** Float. Range: 0.0...1.0. Default: 0.6

Returns instance of class Result.


#reference( hash )

Parse reference string and run heuristic. It expects that authors are separated by colon.

Hash arguments are:

* **:reference**   String
* **:threshold**   Float. Range: 0.0...1.0. Default: 0.6

Returns instance of class Result.

