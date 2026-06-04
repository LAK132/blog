#! /bin/sh
do_check() {
	for file in $1/*.tex; do
		aspell --personal=${PWD}/words.txt -t -d en_AU -c $file
	done
}

while [ "$1" != "" ]
do
	case $1 in
		all)
			do_check .
			for post in posts/*/; do
				do_check ${post%*/}
			done
		;;

		root)
			do_check .
		;;

		*)
			do_check posts/$1
		;;
	esac
	shift
done
