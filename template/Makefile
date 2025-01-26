prepare:
	-mv frame.fodt frame_old.fodt
	cp reference.fodt frame.fodt


test_style:
	loffice --headless --invisible --convert-to odt --outdir . frame.fodt
	../scripts/generate.sh --test test.asc

generate_template:
	loffice --headless --invisible --convert-to odt --outdir . frame.fodt
	-mv template.fodt template_old.fodt
	-mv style.fodt style_old.fodt
	../scripts/clean_template.sh --template=template.fodt --style=style.fodt frame.fodt
	loffice --headless --invisible --convert-to odt --outdir . style.fodt

test_template:
	../scripts/generate.sh test.asc
