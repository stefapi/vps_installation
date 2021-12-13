#! /bin/bash

set -x
asciidoctor -a toc -a data-uri -a allow-uri-read -b html rasphome_installation.asc
asciidoctor-pdf -a toc -a data-uri -a allow-uri-read -d book rasphome_installation.asc
asciidoctor -a toc -a allow-uri-read -b docbook rasphome_installation.asc
pandoc -f docbook --toc -t rst rasphome_installation.xml -o rasphome_installation.tmp
echo '
.. toctree::
   :maxdepth: 2
   :caption: Table des matières

' > rasphome_installation.rst
cat rasphome_installation.tmp >> rasphome_installation.rst
rm rasphome_installation.tmp
pandoc -f docbook  --toc rasphome_installation.xml -o rasphome_installation.epub -t epub
