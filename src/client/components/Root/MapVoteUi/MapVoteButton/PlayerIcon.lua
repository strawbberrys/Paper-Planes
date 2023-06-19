local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

type Props = {
	imageId: number,
}

local function PlayerIcon(props: Props)
	local icon = New("ImageLabel")({
		Image = props.imageId,

		[Children] = {
			New("UICorner")({
				CornerRadius = UDim.new(1, 0),
			}),

			New("UIAspectRatioConstraint")({}),
		},
	})

	return icon
end

return PlayerIcon
