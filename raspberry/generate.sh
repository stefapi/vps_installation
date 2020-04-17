#! /bin/bash

asciidoctor -a toc -a data-uri -a allow-uri-read -b html raspberry_installation.asc
asciidoctor-pdf -a toc -a data-uri -a allow-uri-read -d book raspberry_installation.asc
asciidoctor -a toc -a allow-uri-read -b docbook raspberry_installation.asc
pandoc -f docbook -t rst raspberry_installation.xml -o raspberry_installation.rst
pandoc -f docbook  raspberry_installation.xml -o raspberry_installation.epub -t epub
