if not getgenv().ExecutorSupport then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/main/executorTest.lua"))()
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/main/places/" .. game.GameId .. ".lua"))()