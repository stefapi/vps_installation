#! /bin/bash

# Install first asciidoctor and asciidoctor diagram which are Ruby modules
# gem install asciidoctor-diagram

set -x
asciidoctor -r asciidoctor-diagram -a toc -a data-uri -a allow-uri-read -a source-highlighter=rouge -b html raspfront_installation.asc
asciidoctor-pdf -r asciidoctor-diagram -a toc -a data-uri -a allow-uri-read -a source-highlighter=rouge -d book raspfront_installation.asc
asciidoctor -r asciidoctor-diagram -a toc -a allow-uri-read -a source-highlighter=rouge -b docbook raspfront_installation.asc
pandoc -f docbook -t rst raspfront_installation.xml -o raspfront_installation.tmp
echo '
.. toctree::
   :maxdepth: 2
   :caption: Table des matières

' > raspfront_installation.rst
cat raspfront_installation.tmp >> raspfront_installation.rst
rm raspfront_installation.tmp
pandoc -f docbook  --toc raspfront_installation.xml -o raspfront_installation.epub -t epub
