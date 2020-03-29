#! /bin/bash

asciidoctor -a toc -a data-uri -b html vps_installation.asc
asciidoctor-pdf -a toc -a data-uri -d book vps_installation.asc
asciidoctor -b docbook vps_installation.asc
pandoc -f docbook -t rst vps_installation.xml -o vps_installation.rst
