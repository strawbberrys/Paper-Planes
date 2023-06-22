local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.knit)
local Promise = require(packages.promise)
local Sift = require(packages.sift)
local Signal = require(packages.signal)
local generateMap = require(script.Parent.Parent.generateMap)
local utility = require(script.Parent.Parent.utility)

--[=[
    @class MatchService
    @tag Service

    The service to handle every match.
]=]
local MatchService = Knit.CreateService({
	Name = "MatchService",

	map = nil,
	rounds = nil,
	duration = nil,
	contestants = nil,
	controller = nil,
	mapConfig = nil,
	matchActive = false,

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
	--- The Players who will be participating in the Match.
	contestants: { Player },
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

	local map = generateMap(config.map, config.mapConfig)
	map:PivotTo(CFrame.identity)
	map.Parent = workspace

	self.matchActive = true

	self.matchStarted:Fire()
	self.Client.matchStarted:FireAll()

	Promise.new(function(resolve)
		for _round = 1, config.rounds do
			local controller = utility.getRandomPlayer()
			self.controller = controller

			local roundDetails = {
				duration = self.roundDuration,
				controller = controller,
			}

			utility.teleportPlayers(self.contestants, map.MatchTable.Boxes.BoxesTop.CFrame)
			utility.teleportPlayer(self.controller, map.MatchControllerSpawn.CFrame)

			self.roundStarted:Fire(roundDetails)
			self.Client.roundStarted:FireAll(roundDetails)

			task.wait(self.roundDuration)

			self.roundStopped:Fire()
			self.Client.roundStopped:FireAll()
		end

		resolve(true)
	end):andThen(function()
		MatchService:__stopMatch()
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
	local success = MatchService:__startMatch(config)

	if not success then
		return false
	end

	return MatchService.matchStopped:Wait()
end

return MatchService
