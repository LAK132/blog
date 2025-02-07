#! /bin/sh
rm -rf build
mkdir -p build

rm -rf output
mkdir -p output

do_dir() {
	mkdir -p build/$1

	mkdir -p output/$1

	[ -d $1/resources ] && cp -r $1/resources output/$1/
	cp style.css output/$1/

	root_dir=$(pwd)
	build_dir=$root_dir/build/$1
	out_dir=$root_dir/output/$1
	( cd $1 && \
		pandoc \
			--from=latex \
			--to=html \
			--standalone \
			--number-sections \
			$( [ "$1" != "." ] && echo --table-of-contents ) \
			--listings \
			--gladtex \
			--metadata=link-citations:true \
			--csl=$root_dir/acm-sigchi-proceedings.csl \
			--lua-filter=$root_dir/filter.lua \
			--resource-path=.:$build_dir:$out_dir \
			--output=$build_dir/index.htex \
			--css=style.css \
			--include-in-header=meta.html \
			$( [ -f bibliography.bib ] && echo --bibliography=bibliography.bib ) \
			main.tex && \
		cd $out_dir && \
		( gladtex \
			-d math \
			-o index.html \
			-u "" \
			$build_dir/index.htex 2> /dev/null
		)
	)
	# gladtex seems to be running into an issue with python
}

do_dir .
for post in posts/*/; do
	mkdir -p build/$post && do_dir ${post%*/}
done
