local _M = { version = "2.0.0" }

local bit = require("bit")
local ffi = require("ffi")
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
struct stat{
    unsigned long   st_dev;
    unsigned long   st_ino;
    unsigned long   st_nlink;
    unsigned int    st_mode;
    unsigned int    st_uid;
    unsigned int    st_gid;
    unsigned int    __pad0;
    unsigned long   st_rdev;
    long            st_size;
    long            st_blksize;
    long            st_blocks;
    unsigned long   st_atime;
    unsigned long   st_atime_nsec;
    unsigned long   st_mtime;
    unsigned long   st_mtime_nsec;
    unsigned long   st_ctime;
    unsigned long   st_ctime_nsec;
    long            __unused[3];
};

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
			if dirent ~= nil then
				return ffi.string(dirent.d_name)
			end
			ffi.C.closedir(dir)
		end
	end
end

local function is_file(filepath)
	local buf = ffi.new("struct stat")
	if ffi.C.syscall(4, filepath, buf) == -1 then
		return false
	end
	return bit.band(buf.st_mode, 0xF000) == 0x8000
end

local function list_files(dir, suffix)
	local files = {}
	local suffix = suffix or "^.*"
	for f in list_dir(dir) do
		if is_file(dir .. "/" .. f) then
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
_M.fork = fork
_M.kill = kill
_M.execlp = execlp
_M.waitpid = waitpid
_M.sleep = sleep
_M.module_available = module_available
return _M
