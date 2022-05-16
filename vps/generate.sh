#! /bin/bash

# Install first asciidoctor and asciidoctor diagram which are Ruby modules
# gem install asciidoctor-diagram

set -x
asciidoctor -r asciidoctor-diagram -a toc -a data-uri -a allow-uri-read -a source-highlighter=rouge -b html vps_installation.asc
asciidoctor-pdf -r asciidoctor-diagram -a toc -a data-uri -a allow-uri-read -a source-highlighter=rouge -d book vps_installation.asc
asciidoctor -r asciidoctor-diagram -a toc -a allow-uri-read -a source-highlighter=rouge -b docbook vps_installation.asc
pandoc -f docbook -t rst vps_installation.xml -o vps_installation.tmp
echo '
.. toctree::
   :maxdepth: 2
   :caption: Table des matières

' > vps_installation.rst
cat vps_installation.tmp >> vps_installation.rst
rm vps_installation.tmp
pandoc -f docbook  --toc vps_installation.xml -o vps_installation.epub -t epub
