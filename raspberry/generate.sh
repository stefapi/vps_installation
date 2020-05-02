#! /bin/bash

asciidoctor -a toc -a data-uri -a allow-uri-read -b html raspberry_installation.asc
asciidoctor-pdf -a toc -a data-uri -a allow-uri-read -d book raspberry_installation.asc
asciidoctor -a toc -a allow-uri-read -b docbook raspberry_installation.asc
pandoc -f docbook --toc -t rst raspberry_installation.xml -o raspberry_installation.tmp
echo '
.. toctree::
   :maxdepth: 2
   :caption: Table des matières

' > raspberry_installation.rst
cat raspberry_installation.tmp >> raspberry_installation.rst
rm raspberry_installation.tmp
pandoc -f docbook  --toc raspberry_installation.xml -o raspberry_installation.epub -t epub
