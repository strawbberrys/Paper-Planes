local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

local font = Font.fromId(12187607287)

local function MapVoteButton(props)
    local ImageButton = New("ImageButton")({
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 2,
        Size = UDim2.new(0, 200, 1, 0),
        Image = props.image,

        [Children] = {
            New("TextLabel")({
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.fromScale(1, 0.1),
                FontFace = font,
                Text = props.mapName,
                TextScaled = true,
            }),

            New("UIAspectRatioConstraint")({})
        }
    })

    return ImageButton
end

return MapVoteButton