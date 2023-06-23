local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.Fusion)
local Knit = require(packages.Knit)

local MatchService = Knit.GetService("MatchService")

local New, Value = Fusion.New, Fusion.Value
local Children = Fusion.Children

local ComponentBase = require(script.Parent.ComponentBase)

local font = Font.fromId(12187374954, Enum.FontWeight.Bold)
local timerFormat = "%02d:%02d"

type Props = {
	Size: Vector2,
	LayoutOrder: number,
}

local function Timer(props: Props)
	local minutesRemainingText = Value("00:00")

	MatchService.roundStarted:Connect(function(roundDetails)
		for totalSeconds = roundDetails.duration, 1, -1 do
			local minutesRemaining = math.floor(totalSeconds / 60)
			local secondsRemaining = math.floor(totalSeconds % 60)
			local formattedTime = string.format(timerFormat, minutesRemaining, secondsRemaining)

			minutesRemainingText:set(formattedTime)

			task.wait(1)
		end
	end)

	return ComponentBase({
		Name = "Timer",

		LayoutOrder = props.LayoutOrder,
		Size = props.Size,

		[Children] = New("TextLabel")({
			Name = "Value",

			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.9),
			ZIndex = 2,

			FontFace = font,
			Text = minutesRemainingText,
			TextScaled = true,
		}),
	})
end

return Timer
