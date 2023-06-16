local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Match = require(ServerScriptService.server.Match)

local Knit = require(ReplicatedStorage.packages.knit)
local MapVoteService = require(ServerScriptService.server.MapVoteService)

Knit.Start():catch(warn):await()

local function runGame()
    MapVoteService:startMapVote({ReplicatedStorage.maps.bedroom}, 15)
    print("Started map vote")

    local mostVotedMap = MapVoteService.mapVoteStopped:Wait()
    print(`map vote ended: {mostVotedMap}`)
end

task.delay(5, runGame)

print("Server started")

-- local match = Match.new({
--     contestants = {},
--     controller = game:GetService("Players"):GetPlayers()[1],
--     duration = 15,
--     rounds = 5,
--     map = ReplicatedStorage.maps.bedroom,
--     mapConfig = {
--         boxConfig = {
--             perRow = 3,
--             perColumn = 3,
--             layers = 6,
--             template = Instance.new("Model")
--         }
--     },
-- })

-- match:start()