local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local t = require(packages.t)

local check = {}

function check.mapTemplate(mapTemplate)
	return t.instanceOf("Model", {
		MatchTable = t.instanceOf("Model", {
			TableTop = t.intersection(t.instanceIsA("BasePart"), t.instanceOf("Model")),
		}),
	})(mapTemplate)
end

function check.boxTemplate(boxTemplate) end

function check.boxConfig(boxConfig) end

function check.mapConfig(mapConfig) end

function check.matchConfig(matchConfig) end

return check

-- i shoulnd't be doing this, each check should be in its script that it's needed. this is un-nessesary.
