#! /bin/bash

# Install on your linux system Asciidoctor, libre office and pandoc (mandatory components)
# Install first asciidoctor and asciidoctor diagram which are Ruby modules
# gem install asciidoctor-diagram
# gem install asciimath

# Installation for qrcode generation
# gem install barby
# gem install rqrcode

# Installation for epub3 generation
# gem install asciidoctor-epub3

# Installation for reducer to generate a flat asciidoctor document for AI purpose 
# gem install asciidoctor-reducer

# This program generates from an  initial asciidoctor file https://docs.asciidoctor.org/asciidoc/latest/ (and all dependencies), An openoffice document, A PDF file conform with company templates, a revision history, an approval zone and an updated table of content.
# Source document supports image integration but also asciidoctor diagrams https://docs.asciidoctor.org/diagram-extension/latest/
# Refer to pssi.asc and parse.py in order to understand how document headers are formatted

#set -x

# Default values
prog=`realpath "$0"`
prog_dirname=`dirname $prog`
template_dir=`realpath "$prog_dirname"/../template`
outdir=`realpath .`
testf=n

# Parsing des arguments
for arg in "$@"; do
  case $arg in
    --template=*)
      template_dir="${arg#*=}"
      ;;
    --outdir=*)
      outdir="${arg#*=}"
      ;;
    --ofile=*)
      ofile="${arg#*=}"
      ;;
    --test)
      testf=y
      ;;
    *)
      if [[ -z "$file" ]]; then
        file="$arg"
      else
        echo "Erreur : Trop d'arguments non optionnels fournis."
        exit 1
      fi
      ;;
  esac
done

# Vérification de l'argument obligatoire
if [[ -z "$file" ]]; then
  echo "Erreur : Un nom de fichier doit être fourni."
  echo "Usage : $0 [--ofile=<file>] [--template=<dir>] [--outdir=<dir>] <filename>"
  exit 1
fi

file=`realpath "$file"`
outdir=`realpath "$outdir"`
ofile=${ofile:-$file}
ofile=`basename "$ofile"`
ofile=$outdir/${ofile%%.*}
template_dir=`realpath "$template_dir"`

mkdir -p "$outdir"

# first generate diagrams, code highlighting, link to images and a docbook
asciidoctor -D"$outdir" -r asciidoctor-diagram -a allow-uri-read -a source-highlighter=rouge -b docbook -o "$ofile.xml" "$file"

# 20/12/2024: bug in asciidoctor which generates attributes not compatible with pandoc docbook input filter
sed -i 's/contentwidth/width/g' "$ofile.xml"
sed -i 's/contentdepth/depth/g' "$ofile.xml"

# prepare document for pandoc. Suppress first <simpara> element if any which contains elements not part of the output file

awk 'BEGIN { found=0 } 
	 /<section/ && !found { found=1 }
     /<simpara>/ && !found { found=1; toskip=1; next } 
     toskip && /<\/simpara>/ { toskip=0; next } 
     { if (!toskip) print }' "$ofile.xml" | sed 's/<?asciidoc-pagebreak?>/saut_de_page784567/g' > "$outdir"/temporary_file.xml

if [[ $testf = y ]]; then
pandoc -f docbook -t odt -L $prog_dirname/admonition.lua --reference-doc="$template_dir"/frame.odt "$outdir"/temporary_file.xml -o "$ofile.odt"
else
pandoc -f docbook -t odt -L $prog_dirname/admonition.lua --template="$template_dir"/template.fodt --reference-doc="$template_dir"/style.odt "$outdir"/temporary_file.xml -o "$ofile.odt"
fi
loffice --headless --invisible --convert-to fodt --outdir "$outdir" "$ofile.odt"

# treat fields in fodt file from xml: title, author, signature table, revision table

$prog_dirname/parse.py "$ofile.xml" "$ofile.fodt" "$outdir"/output.fodt
mv "$outdir"/output.fodt "$ofile.fodt"

if [[ $testf = n ]]; then
# Copy Table format from TemplateTable
loffice  --headless --invisible "vnd.sun.star.script:Standard.module1.CopyFormattingFromTemplate?language=Basic&location=document" "$ofile.fodt"
#loffice  "vnd.sun.star.script:Standard.module1.CopyFormattingFromTemplate?language=Basic&location=document" "$ofile.fodt"
# calculate Table of Content
loffice  --headless --invisible "vnd.sun.star.script:Standard.module1.UpdateIndexes?language=Basic&location=document" "$ofile.fodt"
fi


# generate output documents
loffice --headless --invisible --convert-to odt --outdir "$outdir" "$ofile.fodt"
loffice --headless --invisible --convert-to docx --outdir "$outdir" "$ofile.fodt"
loffice --headless --invisible --convert-to pdf --outdir "$outdir" "$ofile.odt"

# generate a flat asciidoctor file for AI. extension is adoc to indicate chatgpt that this document is an asciidoc
asciidoctor-reducer -o "$ofile.adoc" "$file"

# generate rst file for readthedocs site
pandoc -f docbook -t rst "$outdir"/temporary_file.xml -o "$ofile".tmp
echo '
.. toctree::
   :maxdepth: 2
   :caption: Table des matières

' > "$ofile".rst
cat "$ofile".tmp >> "$ofile".rst

rm "$ofile.xml" "$outdir"/temporary_file.xml "$ofile".tmp
