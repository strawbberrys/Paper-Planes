local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.packages.knit)
Knit.AddServices(script.services)
Knit.Start():catch(warn):await()

local MapVoteService = Knit.GetService("MapVoteService")
local MatchService = Knit.GetService("MatchService")

local function runGame()
	while true do
		local mapDetails = MapVoteService:doMapVote({ ReplicatedStorage.maps.bedroom }, 15)

		MatchService:doMatch({
			contestants = {},
			roundDuration = 15,
			rounds = 5,
			map = mapDetails.map,
			mapConfig = {
				boxConfig = {
					perRow = 3,
					perColumn = 3,
					layers = 6,
					template = Instance.new("Model"),
				},
			},
		})

		task.wait(5) -- intermission
	end
end

task.spawn(runGame)

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
