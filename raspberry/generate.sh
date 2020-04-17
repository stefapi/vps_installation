#! /bin/bash

asciidoctor -a toc -a data-uri -a allow-uri-read -b html raspberry.asc
asciidoctor-pdf -a toc -a data-uri -a allow-uri-read -d book raspberry.asc
asciidoctor -a toc -a allow-uri-read -b docbook raspberry.asc
pandoc -f docbook -t rst raspberry.xml -o raspberry.rst
pandoc -f docbook  raspberry.xml -o raspberry.epub -t epub
