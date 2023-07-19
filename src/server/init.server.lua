local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.Knit)

Knit.AddServices(script.services)
Knit.Start():catch(warn):await()

local MapVoteService = Knit.GetService("MapVoteService")
local MatchService = Knit.GetService("MatchService")
local PopupService = Knit.GetService("PopupService")

local function main(): never
	print("Server started")

	while true do
		local mapDetails = MapVoteService:doMapVote({ ReplicatedStorage.maps.bedroom }, 15)

		MatchService:doMatch({
			roundDuration = 15,
			rounds = 5,
			map = mapDetails.map,
			mapConfig = {
				boxConfig = {
					perRow = 3,
					perColumn = 3,
					layers = 5,
					boxHeight = 20,
					template = ReplicatedStorage.maps.bedroomBox,
				},
			},
		})

		-- PopupService:createPopup({
		-- 	title = "Intermission",
		-- 	description = "Short intermission between matches",
		-- 	duration = 5,
		-- }):await() -- this is not implemented yet

		task.wait(5)
	end
end

main()
