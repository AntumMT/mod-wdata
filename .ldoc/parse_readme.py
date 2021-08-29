#!/usr/bin/env python

import sys, os, codecs, errno, shutil


f_script = os.path.realpath(__file__)
d_ldoc = os.path.dirname(f_script)
d_root = os.path.dirname(d_ldoc)

vinfo = "master"
if len(sys.argv) > 1:
	vinfo = sys.argv[1]

f_readme_src = os.path.join(d_root, "README.md")
f_readme_tgt = os.path.join(d_ldoc, "README.md")

if not os.path.isfile(f_readme_src):
	print("ERROR: source README.md does not exists")
	sys.exit(errno.ENOENT)

print("\nparsing {}".format(f_readme_src))

buffer = codecs.open(f_readme_src, "r", "utf-8")
if not buffer:
	print("ERROR: could not open source README.md for reading")
	sys.exit(1)

r_data = buffer.read()
buffer.close()

r_data = r_data.replace("\r\n", "\n").replace("\r", "\n")
r_lines = r_data.split("\n")
r_lines_pre = []
r_lines_post = []
table = []

links = {}

for line in r_lines:
	if line.startswith("[") and "]: " in line:
		link = line.lstrip("[").split("]: ")
		links[link[0]] = link[1]

def escape_underscore(li, in_code=False):
	if in_code:
		return li

	characters = []
	for c in li:
		if c == "`":
			if not in_code:
				in_code = True
			else:
				in_code = False

		if c == "_" and not in_code:
			c = "\\_"

		characters.append(c)

	return "".join(characters)


mid = False
post = False
indent = False
in_code = False
for line in r_lines:
	if line.startswith("###"):
		line = line.rstrip(":")
	elif line.startswith("```"):
		if not in_code:
			in_code = True
		else:
			in_code = False

	'''
	if line.count("_") > 1:
		line = line.replace("_", "\\_")
	'''

	if line == "![screenshot](screenshot.png)":
		line = '<img src="../screenshot.png" width="700" />'
	elif line == "See [sources.md](sources.md)":
		line = "See <a href=\"https://github.com/AntumMT/mod-sounds/blob/{}/sources.md\">sources.md</a>".format(vinfo)
	elif line.startswith("|"):
		mid = True

	if mid:
		if line.startswith("|"):
			if line.startswith("| Filename"):
				line = "{}\n".format(line.lstrip("| ").rstrip(" |")).replace("_", "\\_")
			else:
				#if line.replace("-", "").replace("|", "").strip() == "":
				if line.strip(" -|") == "":
					continue

				#line = "- {}".format(line.lstrip("|").rstrip(" |"))

				line = line.lstrip("| ").rstrip(" |")
				cols = line.split("|")
				for idx in range(len(cols)):
					cols[idx] = cols[idx].strip()

				url = None
				sname = cols[0]
				lname = None
				author = cols[1]
				lic = cols[2]
				notes = None
				if len(cols) > 3:
					notes = cols[3]

				if "][]" in sname:
					sname = sname.strip("[]")
					lname = sname
				elif "][" in sname:
					tmp = sname.split("][")
					sname = tmp[0].strip("[]")
					lname = tmp[1].strip("[]")

				if lname and lname in links:
					url = links[lname]

				sname = sname.replace("_", "\_")
				author = author.replace("_", "\_").replace("↓", "🡇")

				line = "- "
				if url:
					line = '{} <a href="{}">'.format(line, url)
				line = "{}{}".format(line, sname)
				if url:
					line = "{}</a>".format(line)
				line = "{} by {} ({})".format(line, author, lic)
				if notes:
					line = "{} ({})".format(line, notes)

			while "  " in line:
				line = line.replace("  ", " ")

		if line.startswith("#####"):
			line = "<br/>\n{}".format(line)

		# authors cont.
		if not indent and line.startswith("\t- "):
			line = line.replace("\t- ", "<ul>\n<li>").replace("**", "<b>", 1).replace("**", "</b>", 1)
			indent = True
		elif indent:
			if not line.startswith("\t- "):
				indent = False
				line = "</ul>\n{}".format(line)
			else:
				line = line.replace("\t- ", "<li>").replace("**", "<b>", 1).replace("**", "</b>", 1)
			'''
			line = "</ul>\n{}".format(line)
			indent = False
			'''

		table.append(line)

	if line == "### Usage:":
		post = True
		mid = False
		continue

	if post:
		r_lines_post.append(escape_underscore(line, in_code))
	elif not mid:
		r_lines_pre.append(escape_underscore(line, in_code))

buffer = codecs.open(f_readme_tgt, "w", "utf-8")
if not buffer:
	print("ERROR: could not open target README.md for writing")
	sys.exit(1)

buffer.write("{}\n\n{}\n\n{}".format("\n".join(r_lines_pre), "\n".join(table), "\n".join(r_lines_post)))
buffer.close()

print("Exported README.md to {}\n".format(f_readme_tgt))
