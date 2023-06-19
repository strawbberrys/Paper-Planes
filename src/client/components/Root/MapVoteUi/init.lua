local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)
local Knit = require(packages.knit)

local MapVoteService = Knit.GetService("MapVoteService")

local New, Value, ForValues = Fusion.New, Fusion.Value, Fusion.ForValues
local Children = Fusion.Children

local MapVoteButton = require(script.MapVoteButton)

local font = Font.fromId(12187607287)

type Props = {}

local function MapVoteUi(props: Props)
	local mapVoteActive = Value(false)
	local mapVoteList = Value({})
	local mapVoteButtons = ForValues(mapVoteList, function(mapData)
		return MapVoteButton(mapData)
	end, Fusion.doNothing)

	local MapVoteFrame = New("Frame")({
		Name = "MapVoteFrame",

		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.3,
		Size = UDim2.fromScale(1, 1),
		Visible = mapVoteActive,
		ZIndex = 10000,

		[Children] = {
			New("TextLabel")({
				Name = "Label",

				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.171),
				Size = UDim2.fromScale(1, 0.085),
				FontFace = font,
				Text = "Vote for the next map!",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextStrokeTransparency = 0,
			}),

			New("Frame")({
				Name = "MapVoteList",

				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0, 0.2),

				[Children] = {
					New("UIListLayout")({
						Padding = UDim.new(0, 10), -- convert this to scale if possible
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					mapVoteButtons,
				},
			}),
		},
	})

	MapVoteService.mapVoteStarted:Connect(function(mapList)
		mapVoteList:set(mapList)
		mapVoteActive:set(true)
	end)

	MapVoteService.mapVoteStopped:Connect(function(mostVotedMap)
		mapVoteActive:set(false)
		mapVoteList:set({})
	end)

	return MapVoteFrame
end

return MapVoteUi
