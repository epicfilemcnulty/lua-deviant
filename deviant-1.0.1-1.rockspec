package = "deviant"
 version = "1.0.1-1"
 source = {
    url = "git+https://github.com/epicfilemcnulty/lua-deviant.git",
    tag = "v1.0.1"
 }
 description = {
    summary = "A set of small useful functions extending lua's standard library",
    detailed = [[
        Lua module with a set of functions extending standard libraries:
        copying & merging tables, working with files, working with modules.
    ]],
    homepage = "https://github.com/epicfilemcnulty/lua-deviant.git",
    license = "GPLv3"
 }
 dependencies = {
    "lua >= 5.1",
    "luafilesystem >= 1.8"
 }
 build = {
    type = "builtin",
    modules = {
       deviant = "src/deviant.lua"
    }
 }
