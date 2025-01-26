#! /bin/bash

# This program cleans a style document to generate a template file from it

#set -x

# Default values
prog=`realpath "$0"`
prog_dirname=`dirname $prog`
template_dir=`realpath "$prog_dirname"/../template`
outdir=`realpath .`

# Parsing des arguments
for arg in "$@"; do
  case $arg in
    --style=*)
      sfile="${arg#*=}"
      ;;
    --template=*)
      tfile="${arg#*=}"
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
  echo "Usage : $0 [--ofile=<file>] <filename>"
  exit 1
fi

file=`realpath "$file"`
outdir=`realpath "$outdir"`
tfile=${tfile:-'template'}
tfile=`basename "$tfile"`
tfile=$outdir/${tfile%%.*}
sfile=${sfile:-'style'}
sfile=`basename "$sfile"`
sfile=$outdir/${sfile%%.*}
template_dir=`realpath "$template_dir"`

mkdir -p "$outdir"

$prog_dirname/style.py "$file" "$sfile.fodt"
$prog_dirname/template.py "$sfile.fodt" "$tfile.fodt"
