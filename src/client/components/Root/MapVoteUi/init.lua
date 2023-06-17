local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

local MapVoteButton = require(script.Parent.Parent.Parent.components.MapVoteButton)
local font = Font.fromId(12187607287)

local function MapVoteUi(props)
    local MapVoteButtons = {}
    for index, mapVote in props.mapVotes do
        local MapVoteButton = MapVoteButton({
            image = mapVote.image,
            mapName = mapVote.mapName,
        })

        table.insert(MapVoteButtons, MapVoteButton)
    end

    local MapVoteFrame = New("Frame")({
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.3,
        Name = "MapVoteFrame",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 10000,

        [Children] = {
            New("TextLabel")({
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
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0, 0.171),

                [Children] = {
                    New("UIListLayout")({
                        Padding = UDim.new(0, 10), -- convert this to scale if possible
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),

                    unpack(MapVoteButtons),
                }
            }),
        }
    })

    return MapVoteFrame
end

return MapVoteUi