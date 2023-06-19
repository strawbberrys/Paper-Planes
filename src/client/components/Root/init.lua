local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

local MapVoteUi = require(script.MapVoteUi)

local function Root(_props)
	local RootUi = New("Frame")({
		Name = "Root",

		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			MapVoteUi({}),
		},
	})

	return RootUi
end

return Root
