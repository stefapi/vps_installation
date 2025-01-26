
.PHONY: all vps rasphome raspfront clean

all: vps raspfront rasphome

vps:
	cd vps;../scripts/generate.sh vps_installation.asc --outdir=.
	cd vps;pip-compile --output-file=- > requirements.txt
	
rasphome:
	cd rasphome;../scripts/generate.sh rasphome_installation.asc --outdir=.
	cd rasphome;pip-compile --output-file=- > requirements.txt
	
raspfront:
	cd raspfront;../scripts/generate.sh raspfront_installation.asc --outdir=.
	cd raspfront;pip-compile --output-file=- > requirements.txt
