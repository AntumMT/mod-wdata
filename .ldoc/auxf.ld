
-- Place this file in mod's ".ldoc" directory


local package = import("package")
local require = import("require")

-- START: string

string.ltrim = function(st, delim)
	delim = delim or " "

	while st:find(delim) == 1 do
		st = st:sub(2)
	end

	return st
end

string.rtrim = function(st, delim)
	delim = delim or " "

	while st:sub(#st) == delim do
		st = st:sub(1, #st-1)
	end

	return st
end

string.trim = function(st, delim)
	return string.rtrim(string.ltrim(st, delim), delim)
end

string.split = function(st, delim)
	delim = delim or " "

	-- trim up
	st = string.trim(st, delim)

	local dd = delim .. delim
	while st:find(dd) do
		st:gsub(dd, delim)
	end

	local new_table = {}
	local idx = st:find(delim)
	while idx do
		table.insert(new_table, st:sub(1, idx-1))
		st = st:sub(idx+#delim)
		idx = st:find(delim)
	end

	if st ~= "" then
		table.insert(new_table, st)
	end

	return new_table
end

-- END: string


-- START: system

sys = {
	platform = "unix",
	path_delim = package.config:sub(1, 1)
}

if sys.path_delim == "\\" then
	sys.platform = "win"
end

-- END: system


-- START: filesystem

local normpath = function(path)
	local retval
	if sys.platform == "win" then
		retval = path:gsub("^/c", "C:"):gsub("/", sys.path_delim)
	else
		retval = path:gsub("\\", sys.path_delim):gsub("//", sys.path_delim)
	end

	return retval
end

local path = require("pl.path")
fs = {
	copy = require("pl.file").copy,
	attr = path.attrib,
	exists = path.exists,
	isfile = path.isfile,
	isdir = path.isdir,
	mkdir = path.mkdir,
	--normpath = path.normpath,
	normpath = normpath,
}

local mkdirs = function(dir)
	dir = fs.normpath(dir)

	local path_root = dir:find(sys.path_delim) == 1
	local parts = string.split(dir, sys.path_delim)

	local path = ""
	if sys.platform == "unix" and path_root then
		path = sys.path_delim
	end

	for _, d in ipairs(parts) do
		path = path .. d

		if fs.isfile(path) then
			print("ERROR: [mkdir] file exists: " .. path)
			return false
		end

		if not fs.isdir(path) then
			fs.mkdir(path)
		end

		path = path .. sys.path_delim
	end

	return fs.isdir(dir)
end

fs.mkdirs = mkdirs

-- END: filesystem
