local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children

type Props = {
	Name: string,

	LayoutOrder: number,
	Size: Vector2,

	Children: {},
}

local function ComponentBase(props: Props): Instance
	return New("CanvasGroup")({
		Name = props.Name,

		LayoutOrder = props.LayoutOrder,

		[Children] = {
			New("UICorner")({
				CornerRadius = UDim.new(0.3, 0),
			}),

			New("UISizeConstraint")({
				MinSize = props.Size,
			}),

			New("Frame")({
				Name = "Background",

				BackgroundColor3 = Color3.fromRGB(255, 255, 255), -- might want to make this customizable
				Size = UDim2.fromScale(1, 1),
			}),

			props[Children],
		},
	})
end

return ComponentBase
