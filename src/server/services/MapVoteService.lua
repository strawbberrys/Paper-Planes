local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.Knit)
local Signal = require(packages.Signal)

--[=[
	@class MapVoteService
	@server
	@tag Service

	The service to handle map votes.
]=]
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

--[=[
	@class MapVoteService.Client
	@client
	@tag Service

	The service to handle map votes.
]=]

--[=[
	@type MapDetails { map: Model, mapId: number, votes: number, }
	@within MapVoteService

	The map details.
]=]
type MapDetails = {
	map: Model,
	mapId: number,
	votes: number,
}

--[=[
	Starts a map vote using the given maps.
	Each map model in mapSelection must have these attributes set: MapName, MapIcon.

	@private
]=]
function MapVoteService:__startMapVote(mapSelection: { Model }, duration: number): boolean
	assert(not self.mapVoteActive, "only one map vote can be active at a time.")

	local mapVotes = {}
	local mapDetails = {} :: { MapDetails }

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

	task.delay(duration, MapVoteService.__stopMapVote, self)

	return true
end

--[=[
	Stops the running match vote and cleans up.
	Returns the most voted map details.

	@private
]=]
function MapVoteService:__stopMapVote(): MapDetails
	assert(self.mapVoteActive, "there must be a map vote active first.")

	local mapSelection = self.mapSelection
	local mostVotedMap = { map = nil, mapId = nil, votes = -1 } :: MapDetails

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

--[=[
	Adds a vote to the mapId's vote list.

	@private
]=]
function MapVoteService:__addVote(player: Player, mapId: number): boolean
	if not self.mapVoteActive then
		return false
	end

	local mapVotes = self.mapVotes[mapId]

	if not mapVotes then
		return false
	end

	table.insert(mapVotes, player)
	self.Client.voteAdded:FireAll(player, mapId)

	return true
end

--[=[
	Removes a vote from the mapId's vote list.

	@private
]=]
function MapVoteService:__removeVote(player: Player, mapId: number, index: number?): boolean
	if not self.mapVoteActive then
		return false
	end

	local mapVotes = self.mapVotes[mapId]

	if not mapVotes then
		return false
	end

	index = index or table.find(mapVotes, player)

	if not index then
		return false
	end

	table.remove(mapVotes, index)
	self.Client.voteRemoved:FireAll(player, mapId)

	return true
end

--[=[
	Finds and removes every vote for the player.

	@private
]=]
function MapVoteService:__removeAllVotesForPlayer(player: Player): boolean
	local mapVotes = self.mapVotes

	for mapId = 1, #mapVotes do
		local index = table.find(mapVotes[mapId], player)

		if index then
			local success = MapVoteService:__removeVote(player, mapId, index)

			if not success then
				return false
			end
		end
	end

	return true
end

--[=[
	Adds a vote to the mapId's vote list and removes any other vote the player has.
]=]
function MapVoteService:doVote(player: Player, mapId: number): boolean
	local success1 = MapVoteService:__removeAllVotesForPlayer(player)

	if not success1 then
		return false
	end

	local success2 = MapVoteService:__addVote(player, mapId)

	if not success2 then
		return false
	end

	return true
end

--[=[
	Does an entire map vote.

	@yields
	@return MapDetails -- Most voted map.
]=]
function MapVoteService:doMapVote(mapSelection: { Model }, duration: number): MapDetails
	MapVoteService:__startMapVote(mapSelection, duration)

	return MapVoteService.mapVoteStopped:Wait()
end

--[=[
	Requests a vote to the server.
]=]
function MapVoteService.Client:vote(player: Player, mapId: number)
	return self.Server:doVote(player, mapId)
end

return MapVoteService
