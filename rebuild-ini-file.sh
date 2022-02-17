#!/bin/bash

split_ini () {
	# remove any formerly existing INI file sections in this dir
	rm -f -- \[*

	# split INI file sections to individual files
	# - convert all output files to unix file format
	# - also squeeze blank lines
	WRK_SRC_FILE=$(mktemp)
	tr -d '' < "${SRC_FILE}" > "${WRK_SRC_FILE}"
	/usr/bin/awk '/^\[/ { ofn=$1 } ofn { print > ofn }' "${WRK_SRC_FILE}"
	[[ -f ${WRK_SRC_FILE} ]] && rm "${WRK_SRC_FILE}"
}

rebuild_ini () {
	# new version will end in alpha char, a through j
	# - if it was just a date without alpha version then start with 'a'
	#   dtherwise increment alphabetically up to "j"
	#
	# Should have split out files for rebuilding and it should
	# include the "[Main]" file that has the last updated detail.
	#
	MAIN_FILE="[Main]"
	DATEX=$(date +%Y-%m-%d)
	LAST_UPDATED_LINE=$(grep ^Updated= "${MAIN_FILE}"|tr -d '\r')
	LAST_UPDATED_LINE_VER=${LAST_UPDATED_LINE:(-1)}
	VER=a
	NEW_UPDATED_LINE="Updated=${DATEX}${VER}"
	[[ ${LAST_UPDATED_LINE_VER} = [[:digit:]] ]] || {
		# Last updated line should have alpha version for date
		if [[ ${LAST_UPDATED_LINE_VER} = [[:alpha:]] ]]
		then
			# increment alphabetic ver
			VER=$(echo "${LAST_UPDATED_LINE_VER}"|tr "a-j" "b-k")
			[[ "${VER}" = "k" ]] && {
				echo doing nothing as too many versions already...
				exit 2
			}
		else
			echo bad version char is not alphabetic
			exit 2
		fi
		NEW_UPDATED_LINE="Updated=${DATEX}${VER}"
	}
	# reconstruct INI file
	mapfile -t INI_SECTIONS < <(
		find . -maxdepth 1 -type f -name '\[[0-9]*'|sed 's!^./!!'|sort -V
	)
	[[ ${#INI_SECTIONS[@]} -eq 0 ]] && {
		echo
		echo No INI sections found... quitting
		echo
		exit 2
	}
	(
	cat <<-EOF
		; RDP Wrapper Library configuration
		; Do not modify without special knowledge

		$(cat \[[MPS]*)

		$(cat "${INI_SECTIONS[@]}")

	EOF
	) |cat -s > ./"${SRC_FILE}".new

	# update "Updated=" entry
	sed -i "s/Updated=.*$/${NEW_UPDATED_LINE}/" "${SRC_FILE}".new

	# convert "${SRC_FILE}".new to ff=dos
	sed -i 's/$/\r/' ./"${SRC_FILE}".new

	# cleanup
	rm -- ./\[[MPS]*
	rm -- ./\[[0-9]*
}

SRC_FILE=./rdpwrap.ini

case "${0##*/}" in
	split-ini-file.sh) split_ini ;;
	rebuild-ini-file.sh) rebuild_ini ;;
	*) echo "No work, incorrect filename...."
		exit 2
		;;
esac

[[ -f ${SRC_FILE} && -f ${SRC_FILE}.new ]] && {
	diff -b --color "${SRC_FILE}" "${SRC_FILE}.new"
}

exit 0
