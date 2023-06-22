local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local New, Value, Computed, Out = Fusion.New, Fusion.Value, Fusion.Computed, Fusion.Out
local Children = Fusion.Children

local Timer = require(script.Timer)
local MenuButton = require(script.MenuButton)
local HealthBar = require(script.HealthBar)

type Props = {}

local function StatusUi(_props: Props)
	local timerScale = Vector2.new(0.7, 7 / 15)
	local menuButtonScale = Vector2.new(4 / 15, 7 / 15)
	local healthBarScale = Vector2.new(1, 7 / 15)

	local absoluteSize = Value(Vector2.new(0, 0))

	local components = {
		Timer({
			LayoutOrder = 1,
			Size = Computed(function()
				return absoluteSize:get() * timerScale
			end),
		}),

		MenuButton({
			LayoutOrder = 2,
			Size = Computed(function()
				return absoluteSize:get() * menuButtonScale
			end),
		}),

		HealthBar({
			LayoutOrder = 3,
			Size = Computed(function()
				return absoluteSize:get() * healthBarScale
			end),
		}),
	}

	local StatusFrame = New("Frame")({
		Name = "StatusFrame",

		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.02),
		Size = UDim2.fromScale(0.163, 0.151),

		[Out("AbsoluteSize")] = absoluteSize,

		[Children] = {
			New("UIGridLayout")({
				CellPadding = UDim2.fromScale(0.025, 0.044),
				CellSize = UDim2.fromOffset(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			New("UIAspectRatioConstraint")({
				AspectRatio = 2,
				AspectType = Enum.AspectType.ScaleWithParentSize,
			}),

			components,
		},
	})

	return StatusFrame
end

return StatusUi
