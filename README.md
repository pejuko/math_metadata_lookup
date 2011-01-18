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


Function reference
------------------

#Lookup#article( hash )

Hash arguments are:

* article id is known
  * **:id**
* article id is unknown 
  * **:title** String
  * **:authors** Array of strings
* both cases
  * **:format** Default is :ruby. One of [:ruby, :text, :html]

Returning value depends on :format option. If the option is :ruby it returns array of hashes with articles metadata else it is formated string.


#Lookup#author_name_forms( hash )

Hash arguments are:

* **:name** String. Author name.
* **:format** The same as i previous function.

Returning value depends on :format option. If the option is :ruby it returns array of authors. Author is array with three elements. The first one is preferred form. The second one is site id. The third element is array of strings. Each string represents alternative name forms.
