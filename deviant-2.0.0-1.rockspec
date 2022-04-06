package = "deviant"
 version = "2.0.0-1"
 source = {
    url = "git+https://github.com/epicfilemcnulty/lua-deviant.git",
    tag = "v2.0.0"
 }
 description = {
    summary = "A set of useful functions extending lua's standard library",
    detailed = [[
        Lua module with a set of functions extending standard libraries:
        copying & merging tables, working with files & processes, checking if a module is available.
        Relies on FFI for some functions, so only works with luajit.
    ]],
    homepage = "https://github.com/epicfilemcnulty/lua-deviant.git",
    license = "GPLv3"
 }
 dependencies = {
    "luajit >= 2.1",
 }
 build = {
    type = "builtin",
    modules = {
       deviant = "src/deviant.lua"
    }
 }
