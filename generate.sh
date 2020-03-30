#! /bin/bash

asciidoctor -a toc -a data-uri -a allow-uri-read -b html vps_installation.asc
asciidoctor-pdf -a toc -a data-uri -a allow-uri-read -d book vps_installation.asc
asciidoctor -a toc -a allow-uri-read -b docbook vps_installation.asc
pandoc -f docbook -t rst vps_installation.xml -o vps_installation.rst
pandoc -f docbook  vps_installation.xml -o vps_installation.epub -t epub
