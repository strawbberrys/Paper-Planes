local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Match = require(ServerScriptService.server.Match)

local match = Match.new({
    contestants = {},
    controller = game:GetService("Players"):GetPlayers()[1],
    duration = 15,
    rounds = 5,
    map = ReplicatedStorage.maps.bedroom,
    mapConfig = {
        boxConfig = {
            perRow = 3,
            perColumn = 3,
            layers = 6,
            template = Instance.new("Model")
        }
    },
})

match:start()