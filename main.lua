local ScriptBranch = "main"

if identifyexecutor and identifyexecutor() == "Solara" then ScriptBranch = "solara" end
loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/" .. ScriptBranch .. "/places/" .. game.GameId .. ".lua"))()
