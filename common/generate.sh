#! /bin/bash

asciidoctor -a toc -a data-uri -a allow-uri-read -b html "$1" -o output.html
