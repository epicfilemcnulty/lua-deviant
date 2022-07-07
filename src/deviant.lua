local _M = { version = "2.1.0" }

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

local ffi
if module_available("ffi") then
	ffi = require("ffi")
else
	ffi = require("cffi")
end

local C = ffi.C

ffi.cdef([[
int fork(void);
int execlp(const char* file, const char *arg, ...);
int waitpid(int pid, int *status, int options);
int kill(int pid, int sig);
unsigned int sleep(unsigned int seconds);

struct dirent {
    int64_t         d_ino;
    size_t          d_off;
    unsigned short  d_reclen;
    unsigned char   d_type;
    char            d_name[256];
};
typedef struct  __dirstream DIR;
DIR *opendir(const char *name);
struct dirent *readdir(DIR *dirp);
int closedir(DIR *dirp);
long syscall(int number, ...);
]])

local function kill(pid, signal)
	return C.kill(pid, signal)
end

local function fork()
	return C.fork()
end

local function execlp(...)
	C.execlp(...)
end

local function waitpid(pid)
	local status = ffi.new("int[1]")
	local WNOHANG = 1
	local id = C.waitpid(pid, status, WNOHANG)
	return id, status
end

local function sleep(seconds)
	C.sleep(seconds)
end

local function list_dir(path)
	local dir, dirent = ffi.C.opendir(path), nil
	return function()
		if dir ~= nil then
			dirent = ffi.C.readdir(dir)
			-- Just comparing with nil here does not work in case of cffi-lua,
			-- it has a special construct for this, nullptr.
			-- This should also work with LuaJIT, its FFI interface does not have
			-- nullptr field, so in case of LuaJIT we will be comparing with nil.
			if dirent ~= ffi.nullptr then
				return ffi.string(dirent.d_name), ffi.tonumber(dirent.d_type)
			end
			ffi.C.closedir(dir)
		end
	end
end

local function list_files(dir, suffix)
	local files = {}
	local suffix = suffix or "^.*"
	for f, t in list_dir(dir) do
		if t == 8 then -- 8 is for regular file, 4 is for dirs
			if f:match(suffix) then
				table.insert(files, f)
			end
		end
	end
	return files
end

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

local function envsubst(filename)
	local content, err = read_file(filename)
	if content then
		return content:gsub("{{([%w%d_]+)}}", function(cap)
			return os.getenv(cap)
		end)
	end
	return nil, err
end

local function render_template(tmpl, subs)
	return string.gsub(tmpl, "{{([%w_]+)}}", subs)
end

_M.merge_tables = merge_tables
_M.copy_table = copy_table
_M.sort_table_keys = sort_table_keys
_M.read_file = read_file
_M.write_file = write_file
_M.file_exists = file_exists
_M.list_files = list_files
_M.fork = fork
_M.kill = kill
_M.execlp = execlp
_M.waitpid = waitpid
_M.sleep = sleep
_M.module_available = module_available
_M.envsubst = envsubst
_M.render_template = render_template
return _M
