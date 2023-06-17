local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)
local Knit = require(packages.knit)
Knit.AddControllers(script.controllers)
Knit.Start():catch(warn):await()

local Root = require(script.components.Root)

local app = Fusion.New("ScreenGui")({
    Name = "App",
    [Fusion.Children] = Root({}),
})

Fusion.Hydrate(app)({
    Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
})

print("Client started")

-- local MapVoteService = Knit.GetService("MapVoteService")

-- MapVoteService.mapVoteStarted:Connect(function(mapVotes)
--     print(`map vote started: {mapVotes}`)
-- end)

-- MapVoteService.mapVoteStopped:Connect(function(mostVotedMap)
--     print(`map vote ended: {mostVotedMap}`)
-- end)

-- MapVoteService.voteAdded:Connect(function(player, mapId)
--     print(`vote added {player} {mapId}`)
-- end)

-- MapVoteService.voteRemoved:Connect(function(player, mapId)
--     print(`vote removed {player} {mapId}`)
-- end)

-- local Knit = require(game:GetService("ReplicatedStorage").packages.knit)
-- Knit.Start():catch(warn):await()

-- local MapVoteService = Knit.GetService("MapVoteService")

-- MapVoteService:vote(1)