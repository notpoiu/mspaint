--// Loading Wait \\--
if shared.LocalPlayer.PlayerGui:FindFirstChild("LoadingUI") and shared.LocalPlayer.PlayerGui.LoadingUI.Enabled then
    repeat task.wait() until not shared.LocalPlayer.PlayerGui.LoadingUI.Enabled
end

shared.Character = shared.LocalPlayer.Character or shared.LocalPlayer.CharacterAdded:Wait()

--// Linoria \\--
local Toggles = shared.Toggles
local Options = shared.Options

--// Variables \\--
local Script = shared.Script
Script.CurrentBadge = 0
Script.Achievements = {
    "SurviveWithoutHiding",
    "SurviveGloombats",
    "SurviveSeekMinesSecond",
    "TowerHeroesGoblino",
    "EscapeBackdoor",
    "SurviveFiredamp",
    "CrucifixDread",
    "EnterRooms",
    "EncounterVoid",
    "Join",
    "DeathAmt100",
    "UseCrucifix",
    "EncounterSpider",
    "SurviveHalt",
    "SurviveRush",
    "DeathAmt10",
    "Revive",
    "PlayFriend",
    "SurviveNest",
    "CrucifixFigure",
    "CrucifixAmbush",
    "PlayerBetrayal",
    "SurviveEyes",
    "KickGiggle",
    "EscapeMines",
    "GlowstickGiggle",
    "DeathAmt1",
    "SurviveSeek",
    "UseRiftMutate",
    "CrucifixGloombatSwarm",
    "SurviveScreech",
    "SurviveDread",
    "SurviveSeekMinesFirst",
    "CrucifixHalt",
    "TowerHeroesVoid",
    "JoinLSplash",
    "CrucifixDupe",
    "EncounterGlitch",
    "JeffShop",
    "CrucifixScreech",
    "SurviveGiggle",
    "EscapeHotelMod1",
    "SurviveDupe",
    "CrucifixRush",
    "EscapeBackdoorHunt",
    "EscapeHotel",
    "CrucifixGiggle",
    "EscapeFools",
    "UseRift",
    "SpecialQATester",
    "EscapeRetro",
    "TowerHeroesHard",
    "EnterBackdoor",
    "EscapeRooms1000",
    "EscapeRooms",
    "EscapeHotelMod2",
    "EncounterMobble",
    "CrucifixGrumble",
    "UseHerbGreen",
    "CrucifixSeek",
    "JeffTipFull",
    "SurviveFigureLibrary",
    "TowerHeroesHotel",
    "CrucifixEyes",
    "BreakerSpeedrun",
    "SurviveAmbush",
    "SurviveHide",
    "JoinAgain"
}

Script.RemotesFolder = shared.ReplicatedStorage:WaitForChild("RemotesFolder")
Script.CreateElevator = Script.RemotesFolder:WaitForChild("CreateElevator")

Script.MainUI = shared.PlayerGui:WaitForChild("MainUI")
Script.LobbyFrame = Script.MainUI:WaitForChild("LobbyFrame")
Script.AchievementsFrame = Script.LobbyFrame:WaitForChild("Achievements")
Script.CreateElevatorFrame = Script.LobbyFrame:WaitForChild("CreateElevator")

Script.LobbyElevators = workspace:WaitForChild("Lobby"):WaitForChild("LobbyElevators")

--// Functions \\--
function Script.Functions.SetupVariables()
    if wax.shared.ExecutorSupport["require"] then
        for achievementName, _ in pairs(wax.require(shared.ReplicatedStorage.Achievements)) do
            if table.find(Script.Achievements, achievementName) then continue end
    
            table.insert(Script.Achievements, achievementName)
        end
    else
        local badgeList = Script.AchievementsFrame:WaitForChild("List", math.huge)

        if badgeList then
            repeat task.wait(0.5) until #badgeList:GetChildren() ~= 0
            
            shared.Connect:GiveSignal(badgeList.ChildAdded:Connect(function(badge)
                if not badge:IsA("ImageButton") then return end
                if table.find(Script.Achievements, badge.Name) then return end
                table.insert(Script.Achievements, badge.Name)
            end))

            for _, badge in pairs(badgeList:GetChildren()) do
                if not badge:IsA("ImageButton") then continue end
                if table.find(Script.Achievements, badge.Name) then continue end

                table.insert(Script.Achievements, badge.Name)
            end
        end
    end
end

function Script.Functions.LoopAchievements()
    task.spawn(function()
        while Toggles.LoopAchievements.Value and not shared.Library.Unloaded do
            if Script.CurrentBadge >= #Script.Achievements then Script.CurrentBadge = 0 end
            Script.CurrentBadge += 1

            local random = Script.Achievements[Script.CurrentBadge]
            Script.RemotesFolder.FlexAchievement:FireServer(random)

            task.wait(Options.LoopAchievementsSpeed.Value)
        end
    end)
end

function Script.Functions.SetupCharacterConnection(newCharacter)
    shared.Character = newCharacter
    shared.Humanoid = shared.Character:FindFirstChildWhichIsA("Humanoid")
    shared.RootPart = shared.Character:FindFirstChild("HumanoidRootPart") or shared.Character.PrimaryPart
end

shared.Load("Utils", "Preset")

--// Tabs \\--
Script.Tabs = {
    Main = shared.Window:AddTab("Main")
}

shared.Load("Tabs", "Main")

--// Code \\--
task.spawn(Script.Functions.SetupVariables)
task.spawn(Script.Functions.LoadPresets)

task.spawn(Script.Functions.SetupCharacterConnection, shared.Character)
shared.Connect:GiveSignal(shared.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.delay(1, Script.Functions.SetupCharacterConnection, newCharacter)
end))

getgenv().mspaint_loaded = true