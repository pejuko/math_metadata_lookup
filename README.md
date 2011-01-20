About
-----

This utility search mathematical reviews sites and fetches metadata about articles.


Command line usage example
--------------------------

Fetching metadata about an article:

    math_metadata_lookup.rb article -t "Sobolev embeddings with variable exponent. II"

Returns list of articles:
    bin/math_metadata_lookup.rb article -t "Sobolev embeddings" -a "Rakosnik, Jiri" -a "Edmunds, David" -f html

Searching for authors:
    bin/math_metadata_lookup.rb author -a "Vesely, Jiri"


Usage from ruby
---------------

    require 'rubygems'
    require 'math_metadata_lookup'

    # initialize search engine to look only to Mathematical Reviews database
    l = MathMetadata:Lookup.new :sites => [:mrev]

    article = l.article( :title => "Sobolev embeddings with variable exponent. II" ).first
    p article[:authors] if article


Resources
---------

Content of the resource directory:

* **``math_metadata_lookup.js``**: contains function ``toggle_references( id )``. It can toggle visibility of references in html document. By default are all references visible. If you set in css class references attribute display to none it will be hidden by default.


Function reference
------------------

#Lookup#article( hash )

Hash arguments are:

* article id is known
  * **:id**
* article id is unknown 
  * **:title** String
  * **:authors** Array of strings

Returns instance of class Result.


#Lookup#author( hash )

Hash arguments are:

* **:name** String. Author name.

Returns instance of class Result.
