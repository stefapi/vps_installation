#! /bin/bash

asciidoctor -a toc -a data-uri -a allow-uri-read -b html vps_installation.asc
asciidoctor-pdf -a toc -a data-uri -a allow-uri-read -d book vps_installation.asc
asciidoctor -a toc -a allow-uri-read -b docbook vps_installation.asc
pandoc -f docbook --toc -t rst vps_installation.xml -o vps_installation.tmp
echo '
.. toctree::
   :maxdepth: 2
   :caption: Table des matières

' > vps_installation.rst
cat vps_installation.tmp >> vps_installation.rst
rm vps_installation.tmp
pandoc -f docbook  --toc vps_installation.xml -o vps_installation.epub -t epub
