#! /bin/bash

# Install first asciidoctor and asciidoctor diagram which are Ruby modules
# gem install asciidoctor-diagram

set -x
asciidoctor -r asciidoctor-diagram -a toc -a data-uri -a allow-uri-read -a source-highlighter=rouge -b html rasphome_installation.asc
asciidoctor-pdf -r asciidoctor-diagram -a toc -a data-uri -a allow-uri-read -a source-highlighter=rouge -d book rasphome_installation.asc
asciidoctor -r asciidoctor-diagram -a toc -a allow-uri-read -a source-highlighter=rouge -b docbook rasphome_installation.asc
pandoc -f docbook -t rst rasphome_installation.xml -o rasphome_installation.tmp
echo '
.. toctree::
   :maxdepth: 2
   :caption: Table des matières

' > rasphome_installation.rst
cat rasphome_installation.tmp >> rasphome_installation.rst
rm rasphome_installation.tmp
pandoc -f docbook  --toc rasphome_installation.xml -o rasphome_installation.epub -t epub
