#!/bin/bash

do_cmd () {

	echo -e "${@}"
	date
	eval "${@}"
	CMD_STATUS=$?
	echo -e "\n -- status: ${CMD_STATUS}\n\n"
	date
	return "${CMD_STATUS}"

}


BN=$(basename "${0}")
SRC_FILE=./rdpwrap.ini

case "${BN}" in
	split-ini-file.sh)
		# remove any formerly existing INI file sections
		rm -f -- \[*

		# split INI file sections to individual files
		# - convert all output files to unix file format
		# - also squeeze blank lines
		cat "${SRC_FILE}"|tr -d ''|cat -s|
		/usr/bin/awk \
			'/^\[/ { ofn=$1 }
				ofn {
						print > ofn
					   	system("sleep 0.0000000001")
					}'

#
# This should NOT be necessary
#
#		# remove  from filenames if created above with them
#		for filex in \[*
#		do
#			filex2=$(echo "${filex}" | tr -d '')
#			[[ "${filex}" = "${filex2}" ]] || {
#				do_cmd mv -v "${filex}" "${filex2}"
#			}
#		done
		;;
	rebuild-ini-file.sh)
		# reconstruct INI file
		(
		cat <<-EOF
			; RDP Wrapper Library configuration
			; Do not modify without special knowledge

		EOF

		for x in ./\[[MPS]*
		do
			cat "${x}"
			echo
		done

		# the following "ls" is to ensure ordering of INI sections...
		for x in $(ls -av -- ./\[[0-9]*)
		do
			cat "${x}"
			echo
		done
		)| tr -d '' |cat -s > ./"${SRC_FILE}".new

		# update "Updated=" entry
		sed -i 's/Updated=.*$/Updated='"$(date +%Y-%m-%d)"'/' "${SRC_FILE}".new

		# convert "${SRC_FILE}".new to ff=dos
		sed -i 's/$/\r/' ./"${SRC_FILE}".new

		# cleanup
		rm -- ./\[[MPS]*
		rm -- ./\[[0-9]*
		;;
esac

