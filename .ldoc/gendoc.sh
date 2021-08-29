#!/usr/bin/env bash

d_ldoc="$(dirname $(readlink -f $0))"
d_root="$(dirname ${d_ldoc})"
d_docs="${d_root}/docs"
f_config="${d_ldoc}/config.ld"

cd "${d_root}"

# Clean old files
rm -rf "${d_docs}/reference"

# Create new files
ldoc -c "${f_config}" -d "${d_docs}/reference" "${d_root}"
