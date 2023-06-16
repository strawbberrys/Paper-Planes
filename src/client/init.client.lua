local Knit = require(game:GetService("ReplicatedStorage").packages.knit)
Knit.Start():catch(warn):await()

local MapVoteService = Knit.GetService("MapVoteService")

MapVoteService.mapVoteStarted:Connect(function(mapVotes)
    print(`map vote started: {mapVotes}`)
end)

MapVoteService.mapVoteStopped:Connect(function(mostVotedMap)
    print(`map vote ended: {mostVotedMap}`)
end)

MapVoteService.voteAdded:Connect(function(player, mapId)
    print(`vote added {player} {mapId}`)
end)

MapVoteService.voteRemoved:Connect(function(player, mapId)
    print(`vote removed {player} {mapId}`)
end)

print("Client started")

-- local Knit = require(game:GetService("ReplicatedStorage").packages.knit)
-- Knit.Start():catch(warn):await()

-- local MapVoteService = Knit.GetService("MapVoteService")

-- MapVoteService:vote(1)