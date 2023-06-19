local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Sift = require(packages.sift)
local generateMap = require(script.Parent.generateMap)

local Match = {}
Match.__index = Match

type MatchConfig = {
	--- The map that will be used in each round.
	map: Model,
	--- The amount of rounds in the Match.
	rounds: number,
	--- The length of each round.
	duration: number,
	--- The Player who will control the launcher.
	controller: Player,
	--- The Players who will be participating in the Match.
	contestants: { Player },
	--- The configuration for the map generation.
	mapConfig: generateMap.MapConfig,
}

--- Creates a new Match.
--- Internally this generates the map for later use.
function Match.new(config: MatchConfig)
	local self = Sift.Dictionary.copyDeep(config)

	local map = generateMap(config.map, config.mapConfig)
	map:PivotTo(CFrame.identity)

	self.map = map

	return setmetatable(self, Match)
end

function Match:start()
	local map = self.map
	map.Parent = workspace
end

return Match
