local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

local ComponentBase = require(script.Parent.ComponentBase)

type Props = {
	Size: Vector2,
	LayoutOrder: number,
}

local function MenuButton(props: Props)
	return ComponentBase({
		Name = "MenuButton",

		LayoutOrder = props.LayoutOrder,
		Size = props.Size,

		[Children] = {
			New("ImageButton")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.6, 0.6),
				ZIndex = 2,

				Image = "rbxtemp://1",
				ImageColor3 = Color3.fromRGB(0, 0, 0),

				[Children] = New("UIAspectRatioConstraint")({
					AspectRatio = 1.127,
					AspectType = Enum.AspectType.ScaleWithParentSize,
				}),
			}),
		},
	})
end

return MenuButton
