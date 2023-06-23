local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.Knit)
local Logger = require(packages.Console)
local Promise = require(packages.Promise)
local Sift = require(packages.Sift)
local Signal = require(packages.Signal)
local generateMap = require(script.Parent.Parent.generateMap)
local utility = require(script.Parent.Parent.utility)

local logger = Logger.new("MatchService")

--[=[
    @class MatchService
    @tag Service

    The service to handle every match.
]=]
local MatchService = Knit.CreateService({
	Name = "MatchService",

	minimumPlayers = 2,

	map = nil,
	rounds = nil,
	roundDuration = nil,
	contestants = nil,
	controller = nil,
	mapConfig = nil,
	matchActive = false,
	roundActive = false,
	roundMap = nil,
	autoStopRoundThread = nil,

	matchStarted = Signal.new(),
	matchStopped = Signal.new(),
	roundStarted = Signal.new(),
	roundStopped = Signal.new(),

	Client = {
		matchStarted = Knit.CreateSignal(),
		matchStopped = Knit.CreateSignal(),
		roundStarted = Knit.CreateSignal(),
		roundStopped = Knit.CreateSignal(),
	},
})

--[=[
    @type MatchConfig { map: Model, rounds: number, roundDuration: number, contestants: { Player }, mapConfig: generateMap.MapConfig, }
    @within MatchService

    The match config.
]=]
type MatchConfig = {
	--- The map that will be used in each round.
	map: Model,
	--- The amount of rounds in the Match.
	rounds: number,
	--- The length of each round in seconds.
	roundDuration: number,
	--- The configuration for the map generation.
	mapConfig: generateMap.MapConfig,
}

--[=[
    @type MatchResult { winner: Player, }
    @within MatchService

    The match result.
]=]
type MatchResult = {
	winner: Player,
}

--[=[
    Starts a match with the given config.
    This will load the map, respawn and teleport the contestants, and fire all needed signals.

    @private
]=]
function MatchService:__startMatch(config: MatchConfig): boolean
	assert(not self.matchActive, "only one match can be active at a time.")

	for property, value in Sift.Dictionary.copyDeep(config) do
		self[property] = value
	end

	logger:Log("Starting match")

	self.matchActive = true

	self.matchStarted:Fire()
	self.Client.matchStarted:FireAll()

	if #Players:GetPlayers() < self.minimumPlayers then
		logger:Log(`Waiting for {self.minimumPlayers} Players to join...`)

		Promise.fromEvent(Players.PlayerAdded, function()
			if #Players:GetPlayers() == self.minimumPlayers then
				return
			end
		end):await()
	end

	Promise.new(function(resolve)
		for _round = 1, self.rounds do
			self:__doRound()
		end

		resolve(true)
	end):andThen(function()
		self:__stopMatch()
	end)

	return true
end

--[=[
    Stops the running match.
    This will unload the map, despawn the players, and fire all needed signals.

    @private
]=]
function MatchService:__stopMatch(): (boolean, MatchResult?)
	assert(self.matchActive, "there must be a match active first.")

	local matchResult = {
		winner = self.controller, -- template for now
	}

	logger:Log("Stopping match")

	self.matchActive = false

	self.matchStopped:Fire(matchResult)
	self.Client.matchStopped:FireAll(matchResult)

	return true, matchResult
end

--[=[
    Does an entire match. Yields until the match is stopped.

    @yields
]=]
function MatchService:doMatch(config: MatchConfig): (boolean, MatchResult?)
	local success = self:__startMatch(config)

	if not success then
		return false
	end

	return self.matchStopped:Wait()
end

--[=[
	Starts a round. Automatically stops the round in [self.roundDuration] seconds.

	@private
]=]
function MatchService:__startRound()
	assert(self.matchActive, "there must be a match active first.")
	assert(not self.roundActive, "there can only be one active round at a time.")

	logger:Log("Starting round")

	local map = generateMap(self.map, self.mapConfig)
	map:PivotTo(CFrame.identity)
	map.Parent = workspace

	local controller = utility.getRandomPlayer()
	self.controller = controller

	local contestants = Sift.Array.removeValue(Players:GetPlayers(), controller)

	local roundDetails = setmetatable({
		duration = self.roundDuration,
		controller = controller,
		contestants = setmetatable(contestants, { __mode = "v" }),
	}, { __mode = "v" })

	utility.teleportPlayers(contestants, map.MatchTable.Boxes.BoxesTop.CFrame)
	utility.teleportPlayer(self.controller, map.MatchControllerSpawn.CFrame)

	for _, contestant: Player in contestants do
		local characterAdded = if contestant.Character
			then Promise.resolve(contestant.Character)
			else Promise.fromEvent(contestant.CharacterAdded)

		characterAdded:andThen(function(character: Model)
			local humanoidAdded = Promise.try(character.WaitForChild, character, "Humanoid")

			humanoidAdded:andThen(function(humanoid: Humanoid)
				humanoid.Died:Connect(function()
					local newContestantsList = Sift.Array.removeValue(self.contestants, contestant)

					self.contestants = newContestantsList

					self.contestantsUpdated:Fire(newContestantsList)
					self.Client.contestantsUpdated:FireAll(newContestantsList)

					if #newContestantsList == 0 then
						self:__stopRound()
						task.cancel(self.autoStopRoundThread)
					end
				end)
			end)
		end)
	end

	self.roundActive = true
	self.roundMap = map

	self.roundStarted:Fire(roundDetails)
	self.Client.roundStarted:FireAll(roundDetails)

	self.autoStopRoundThread = task.delay(self.roundDuration, self.__stopRound, self)

	return true
end

--[=[
	Stops the running round.

	@private
]=]
function MatchService:__stopRound()
	assert(self.matchActive, "there must be a match active first.")
	assert(self.roundActive, "there must be a round active first.")

	logger:Log("Stopping round")

	self.roundActive = false

	self.roundMap:Destroy()
	self.roundMap = nil

	self.roundStopped:Fire()
	self.Client.roundStopped:FireAll()

	return true
end

--[=[
	Does an entire round. Yields until the round is complete.

	@yields
	@private
]=]
function MatchService:__doRound()
	local success = self:__startRound()

	if not success then
		return false
	end

	return self.roundStopped:Wait()
end

return MatchService
