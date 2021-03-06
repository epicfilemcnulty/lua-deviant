package = "deviant"
 version = "2.1.1-1"
 source = {
    url = "git+https://git.deviant.guru/lua/deviant.git",
    tag = "v2.1.1"
 }
 description = {
    summary = "A set of useful functions extending Lua’s standard library",
    detailed = [[
        Lua module with a set of functions extending standard libraries:
        copying & merging tables, working with files & processes, checking if a module is available.
        Relies on FFI for some functions, so you either have to use it with LuaJIT, or have cffi-lua installed.
    ]],
    homepage = "https://git.deviant.guru/lua/deviant.git",
    license = "CC0"
 }
 dependencies = {
    "lua >= 5.1",
 }
 build = {
    type = "builtin",
    modules = {
       deviant = "src/deviant.lua"
    }
 }
