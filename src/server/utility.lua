local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Promise = require(packages.Promise)

local utility = {}

function utility.loadCharacter(player: Player)
	task.defer(player.LoadCharacter, player)

	return Promise.fromEvent(player.CharacterAppearanceLoaded :: any)
end

function utility.teleportPlayer(player: Player, position: CFrame)
	utility.loadCharacter(player):andThen(function(character: Model)
		task.defer(character.PivotTo, character, position)
	end)
end

function utility.teleportPlayers(players: { Player }, position: CFrame)
	for _, player in players do
		utility.teleportPlayer(player, position)
	end
end

function utility.getRandomPlayer(): Player
	local players = Players:GetPlayers()

	return players[math.random(1, #players)]
end

return utility
