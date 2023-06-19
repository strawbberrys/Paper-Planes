local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.knit)
local Signal = require(packages.signal)

local MapVoteService = Knit.CreateService({
	Name = "MapVoteService",

	mapSelection = nil,
	mapVotes = nil,
	mapVoteActive = false,

	playerAddedConnection = nil,

	mapVoteStarted = Signal.new(),
	mapVoteStopped = Signal.new(),

	Client = {
		mapVoteStarted = Knit.CreateSignal(),
		mapVoteStopped = Knit.CreateSignal(),

		voteAdded = Knit.CreateSignal(),
		voteRemoved = Knit.CreateSignal(),
	},
})

--- Starts a map vote using the given maps.
--- Each map model in mapSelection must have these attributes set: MapName, MapIcon
function MapVoteService:startMapVote(mapSelection: { Model }, duration: number): boolean
	assert(not self.mapVoteActive, "only one map vote can be active at once.")

	local mapVotes = {}
	local mapDetails = {}

	for mapId, map in mapSelection do
		local attributes = map:GetAttributes()
		local mapName = attributes.MapName
		local mapIcon = attributes.MapIcon

		mapVotes[mapId] = setmetatable({}, { __mode = "v" })
		mapDetails[mapId] = { mapName = mapName, mapIcon = mapIcon, mapId = mapId }
	end

	self.mapSelection = mapSelection
	self.mapVotes = mapVotes
	self.mapVoteActive = true
	self.mapVoteStarted:Fire(mapVotes)
	self.Client.mapVoteStarted:FireAll(mapDetails)

	self.playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		self.Client.mapVoteStarted:Fire(player, mapDetails)
	end)

	task.delay(duration, self.stopMapVote, self)

	return true
end

function MapVoteService:addVote(player: Player, mapId: number)
	if not self.mapVoteActive then
		return false
	end

	local mapVotes = self.mapVotes[mapId]

	if not mapVotes then
		return false
	end

	MapVoteService:removeVote(player)
	table.insert(mapVotes, player)
	self.Client.voteAdded:FireAll(player, mapId)

	return true
end

function MapVoteService:removeVote(player: Player)
	if not self.mapVoteActive then
		return false
	end

	local allMapVotes = self.mapVotes

	for mapId, mapVotes in allMapVotes do
		local target = table.find(mapVotes, player)

		if target then
			table.remove(mapVotes, target)
			self.Client.voteRemoved:FireAll(player, mapId)

			return true
		end
	end

	return false
end

function MapVoteService:stopMapVote()
	assert(self.mapVoteActive, "there must be a map vote active first.")

	local mapSelection = self.mapSelection
	local mostVotedMap = { map = nil, mapId = nil, votes = -1 }

	for mapId, mapVotes in self.mapVotes do
		local totalVotes = #mapVotes

		if totalVotes > mostVotedMap.votes then
			mostVotedMap.map = mapSelection[mapId]
			mostVotedMap.mapId = mapId
			mostVotedMap.votes = totalVotes
		end
	end

	self.mapVoteActive = false
	self.mapVotes = nil
	self.mapSelection = nil
	self.mapVoteStopped:Fire(mostVotedMap)
	self.Client.mapVoteStopped:FireAll(mostVotedMap)
	self.playerAddedConnection:Disconnect()

	return mostVotedMap
end

function MapVoteService.Client:vote(player: Player, mapId: number)
	return self.Server:addVote(player, mapId)
end

return MapVoteService
