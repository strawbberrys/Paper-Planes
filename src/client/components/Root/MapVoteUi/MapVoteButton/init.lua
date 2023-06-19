local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)
local Knit = require(packages.knit)

local MapVoteService = Knit.GetService("MapVoteService")

local New, Value, ForValues, OnEvent = Fusion.New, Fusion.Value, Fusion.ForValues, Fusion.OnEvent
local Children = Fusion.Children

local PlayerIcon = require(script.PlayerIcon)

local font = Font.fromId(12187607287)

type Props = {
	mapName: string,
	mapIcon: string,
	mapId: number,
}

local function MapVoteButton(props: Props)
	local playerIcons = Value({})
	local playerImageLabels = ForValues(playerIcons, function(iconData)
		return PlayerIcon({ imageId = iconData.imageId })
	end, Fusion.doNothing)

	local MapButton = New("ImageButton")({
		Name = "MapButton",

		BorderColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 2,
		Size = UDim2.new(0, 200, 1, 0),
		Image = props.mapIcon,

		[Children] = {
			New("TextLabel")({
				Name = "MapName",

				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.1),
				FontFace = font,
				Text = props.mapName,
				TextScaled = true,

				[Children] = New("UITextSizeConstraint")({
					MinTextSize = 10,
				}),
			}),

			New("Frame")({
				Name = "PlayerList",

				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.975, 0.025),
				Size = UDim2.fromScale(0.58, 1),

				[Children] = {
					New("UIGridLayout")({
						CellPadding = UDim2.fromScale(0.044, 0.025),
						CellSize = UDim2.fromScale(0.217, 0.126),
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						SortOrder = Enum.SortOrder.LayoutOrder,
						StartCorner = Enum.StartCorner.TopRight,
					}),

					playerImageLabels,
				},
			}),

			New("UIAspectRatioConstraint")({}),
		},

		[OnEvent("Activated")] = function()
			MapVoteService:vote(props.mapId)
		end,
	})

	MapVoteService.voteAdded:Connect(function(player, mapId)
		if mapId == props.mapId then
			local newPlayerIcons = playerIcons:get()

			table.insert(newPlayerIcons, {
				player = player,
				imageId = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=60&h=60`,
			})

			playerIcons:set(newPlayerIcons)
		end
	end)

	MapVoteService.voteRemoved:Connect(function(player, mapId)
		if mapId == props.mapId then
			local newPlayerIcons = playerIcons:get()

			for index, iconData in newPlayerIcons do
				if iconData.player == player then
					table.remove(newPlayerIcons, index)
				end
			end

			playerIcons:set(newPlayerIcons)
		end
	end)

	return MapButton
end

return MapVoteButton
