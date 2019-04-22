#!/bin/bash

BN=$(basename "${0}")

case "${BN}" in
	split-ini-file.sh)
		rm -f -- \[*
		/usr/bin/awk \
			'/^\[/ \
				{ ofn=$1 } \
				ofn {
						print > ofn
					   	system("sleep 0.0000000001")
					}' \
			rdpwrap.ini
		for filex in $(ls -rt \[*)
		do
			mv "${filex}" "$(echo "${filex}" | tr -d '\r')"
		done
		;;
	rebuild-ini-file.sh)
		# reconstruct INI file
		(
		echo -e '; RDP Wrapper Library configuration\r'
		echo -e '; Do not modify without special knowledge\r'
		echo -e '\r'

		for x in $(ls -rt -- ./\[*)
		do
			cat "${x}"
		done) > ./rdpwrap.ini.new
		;;
esac

