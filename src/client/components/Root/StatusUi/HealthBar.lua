local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local player = Players.LocalPlayer

local New, Value, Computed = Fusion.New, Fusion.Value, Fusion.Computed
local Children = Fusion.Children

local ComponentBase = require(script.Parent.ComponentBase)

local font = Font.fromId(12187374954, Enum.FontWeight.Bold)

type Props = {
	Size: Vector2,
	LayoutOrder: number,
}

local function HealthBar(props: Props)
	local health = Value(100)
	local maxHealth = Value(100)
	local healthPercentage = Computed(function()
		return health:get() / maxHealth:get()
	end)

	player.CharacterAdded:Connect(function(character)
		local humanoid: Humanoid = character:WaitForChild("Humanoid")
		health:set(humanoid.Health)
		maxHealth:set(humanoid.MaxHealth)

		humanoid.HealthChanged:Connect(function(newHealth)
			health:set(newHealth)
		end)
	end)

	return ComponentBase({
		Name = "HealthBar",

		LayoutOrder = props.LayoutOrder,
		Size = props.Size,

		[Children] = {
			New("Frame")({
				Name = "Fill",

				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				LayoutOrder = props.LayoutOrder,
				Position = UDim2.fromScale(1, 0),
				Size = Computed(function()
					return UDim2.fromScale(1 - healthPercentage:get(), 1)
				end),
				ZIndex = 2,
			}),

			New("TextLabel")({
				Name = "Value",

				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 0.9),
				ZIndex = 3,

				FontFace = font,
				Text = Computed(function()
					return string.format("%d%%", healthPercentage:get() * 100)
				end),
				TextScaled = true,

				[Children] = New("UIStroke")({
					Color = Color3.fromRGB(255, 255, 255),
				}),
			}),
		},
	})
end

return HealthBar
