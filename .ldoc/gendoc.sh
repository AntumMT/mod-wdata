#!/usr/bin/env bash

d_ldoc="$(dirname $(readlink -f $0))"
d_root="$(dirname ${d_ldoc})"
f_config="${d_ldoc}/config.ld"
d_export="${d_export:-${d_root}/docs/reference}"

cd "${d_root}"

# clean old files
rm -rf "${d_export}"

rm -f "${d_ldoc}/README.md"

if test ! -x "${d_ldoc}/parse_readme.py"; then
	chmod +x "${d_ldoc}/parse_readme.py"
fi

"${d_ldoc}/parse_readme.py"

vinfo="v$(grep "^version = " "${d_root}/mod.conf" | head -1 | sed -e 's/version = //')"
d_data="${d_export}/${vinfo}/data"

# use temp config so sound previews can be linked to master branch
f_config_tmp="${d_ldoc}/config_tmp.ld"
cp "${f_config}" "${f_config_tmp}"
sed -i -e 's/local version = .*$/local version = master/' "${f_config_tmp}"

# create new files
ldoc --UNSAFE_NO_SANDBOX -c "${f_config_tmp}" -d "${d_export}/${vinfo}" "${d_root}"
retval=$?

# check exit status
if test ${retval} -ne 0; then
	echo -e "\nan error occurred (ldoc return code: ${retval})"
	exit ${retval}
fi

# show version info
echo -e "\nfinding ${vinfo}..."
for html in $(find "${d_export}/${vinfo}" -type f -name "*.html"); do
	sed -i -e "s|^<h1>World Data Manager</h1>$|<h1>World Data Manager <span style=\"font-size:12pt;\">(${vinfo})</span></h1>|" "${html}"
done

# copy screenshot
screenshot="${d_root}/screenshot.png"
if test -f "${screenshot}"; then
	cp "${d_root}/screenshot.png" "${d_export}/${vinfo}"
fi

# cleanup
rm -f "${d_ldoc}/README.md" "${f_config_tmp}"

# copy textures to data directory
if test -d "${d_root}/textures"; then
	printf "\ncopying textures ..."
	mkdir -p "${d_data}"
	texture_count=0
	for png in $(find "${d_root}/textures" -maxdepth 1 -type f -name "*.png"); do
		if test -f "${d_data}/$(basename ${png})"; then
			echo "WARNING: not overwriting existing file: ${png}"
		else
			cp "${png}" "${d_data}"
			texture_count=$((texture_count + 1))
			printf "\rcopied ${texture_count} textures"
		fi
	done
fi

echo -e "\n\nDone!"
