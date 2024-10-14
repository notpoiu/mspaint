--[[
    Wax - A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023-2024 Latte Softworks <https://latte.to>
]]

-- You set the following string to "latest" (case insensitive), or any version tag
-- on Wax's releases page (e.g. "0.4.1")
local WaxVersion = "latest"

-------------------------------------------------------------------------------

local Network, Luau, FileSystem = require("@lune/net"), require("@lune/luau"), require("@lune/fs")

local FileLink = if string.lower(WaxVersion) == "latest" then
    "https://github.com/latte-soft/wax/releases/latest/download/wax.luau"
else `https://github.com/latte-soft/wax/releases/download/{WaxVersion}/wax.luau`

if not FileSystem.isDir("Distribution") then
    FileSystem.writeDir("Distribution")
end

Luau.load(Network.request(FileLink).body, {
    debugName = "Wax",
})()

FileSystem.writeFile("Distribution/Script.luau", `{FileSystem.readFile("Build/Header.luau")}\n\n{FileSystem.readFile("Distribution/Script.luau")}`)