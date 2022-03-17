local _M = { version = "1.0.0" }

local lfs = require("lfs")

local function file_exists(filename)
	local f = io.open(filename, "r")
	if f ~= nil then
		io.close(f)
		return true
	end
	return false
end

local function read_file(filename)
	local f, err = io.open(filename, "r")
	if f then
		local lines = f:read("*a")
		f:close()
		return lines
	end
	return nil, err
end

local function write_file(filename, text)
	local f, err = io.open(filename, "w+")
	if f then
		f:write(text)
		f:close()
		return true
	end
	return nil, err
end

local function list_files(path)
	local files = {}
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path .. "/" .. file
			local attr = lfs.attributes(f)
			if attr.mode == "file" then
				table.insert(files, file)
			end
		end
	end
	return files
end

local function list_dirs(path)
	local dirs = {}
	for dir in lfs.dir(path) do
		if dir ~= "." and dir ~= ".." then
			local f = path .. "/" .. dir
			local attr = lfs.attributes(f)
			if attr.mode == "directory" then
				table.insert(dirs, dir)
			end
		end
	end
	return dirs
end

local function copy_table(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

local function merge_tables(defaults, options)
	if options then
		for k, v in pairs(options) do
			if (type(v) == "table") and (type(defaults[k] or false) == "table") then
				mergeTables(defaults[k], options[k])
			else
				defaults[k] = v
			end
		end
	end
	return defaults
end

local function sort_table_keys(t)
	local tkeys = {}
	for k in pairs(t) do
		table.insert(tkeys, k)
	end
	table.sort(tkeys)
	return tkeys
end

local function module_available(name)
	if package.loaded[name] then
		return true
	else
		for _, searcher in ipairs(package.searchers or package.loaders) do
			local loader = searcher(name)
			if type(loader) == "function" then
				package.preload[name] = loader
				return true
			end
		end
		return false
	end
end

_M.merge_tables = merge_tables
_M.copy_table = copy_table
_M.sort_table_keys = sort_table_keys
_M.read_file = read_file
_M.write_file = write_file
_M.file_exists = file_exists
_M.list_files = list_files
_M.list_dirs = list_dirs
_M.module_available = module_available
return _M
