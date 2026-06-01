#! /bin/bash

do_dir() {
	echo processing $1

	[ "$1" != "." ] && rm -rf build/$1
	[ "$1" != "." ] && rm -rf output/$1
	mkdir -p build/$1
	mkdir -p output/$1

	[ -d $1/resources ] && cp -r $1/resources output/$1/
	cp style.css output/$1/

	root_dir=$(pwd)
	build_dir=$root_dir/build/$1
	out_dir=$root_dir/output/$1
	(	cd $1 && \
		pandoc \
			--template=$root_dir/preamble.tex \
			--output=$build_dir/preamble.tex \
			$( [ "$1" != "." ] && echo --metadata=prefix:"$1/" ) \
			$( [ "$1" == "." ] && echo --metadata=prefix:"" ) \
			$root_dir/config.md && \
		pandoc \
			--from=latex \
			--to=html \
			--lua-filter=$root_dir/filter.lua \
			--template=$root_dir/meta.html \
			--standalone \
			--gladtex \
			$( [ "$1" != "." ] && echo --metadata=prefix:"$1/" ) \
			$( [ "$1" == "." ] && echo --metadata=prefix:"" ) \
			--metadata-file=$root_dir/config.md \
			--output=$build_dir/meta.html \
			main.tex && \
		pandoc \
			--from=latex \
			--to=html \
			--lua-filter=$root_dir/filter.lua \
			--template=$root_dir/header.html \
			--standalone \
			--gladtex \
			$( [ "$1" != "." ] && echo --metadata=prefix:"$1/" ) \
			$( [ "$1" == "." ] && echo --metadata=prefix:"" ) \
			--metadata-file=$root_dir/config.md \
			--output=$build_dir/header.html \
			main.tex && \
		pandoc \
			--from=latex \
			--to=html \
			--standalone \
			--number-sections \
			--listings \
			--gladtex \
			$( [ -f bibliography.bib ] && echo \
				--citeproc \
				--metadata=link-citations:true \
				--csl=$root_dir/acm-sigchi-proceedings.csl \
				--bibliography=bibliography.bib ) \
			$( [ "$1" != "." ] && echo \
				--table-of-contents \
				--metadata=prefix:"$1/" ) \
			$( [ "$1" == "." ] && echo \
				--metadata=prefix:"" ) \
			--metadata-file=$root_dir/config.md \
			--lua-filter=$root_dir/filter.lua \
			--resource-path=.:$build_dir:$out_dir \
			--output=$build_dir/index.htex \
			--css=style.css \
			--include-in-header=$build_dir/meta.html \
			--include-before-body=$build_dir/header.html \
			$build_dir/preamble.tex main.tex && \
		(	cd $out_dir && \
			mkdir -p math && \
			( gladtex -d math -o - -u "" $build_dir/index.htex 1> index.html )
		)
	)
}

while [ "$1" != "" ]
do
	case $1 in
		clean)
			rm -rf build
			rm -rf output
		;;

		all)
			do_dir .
			cp favicon.ico output/favicon.ico
			for post in posts/*/; do
				do_dir ${post%*/}
			done
		;;

		root)
			do_dir .
			cp favicon.ico output/favicon.ico
		;;

		*)
			do_dir posts/$1
		;;
	esac
	shift
done
