export type BoxConfig = {
	perRow: number,
	perColumn: number,
	layers: number,
	boxHeight: number,
	template: Part,
}

export type MapConfig = {
	boxConfig: BoxConfig,
}

-- Note that the fillRegion doesn't account for the y-axis, it is only for getting the x & z axis.
-- The y-axis is generated automatically based on the layers given and boxHeight. (Maybe I should change this to automatically generate the box height based on fillRegion.Size.Y?)
local function generateBoxes(fillRegion: Region3, boxConfig: BoxConfig): Model
	local perRow = boxConfig.perRow
	local perColumn = boxConfig.perColumn
	local layers = boxConfig.layers
	local boxHeight = boxConfig.boxHeight
	local template = boxConfig.template

	local boxes = Instance.new("Model")
	boxes.Name = "Boxes"

	local boxSize = Vector3.new(fillRegion.Size.X / perRow, boxHeight, fillRegion.Size.Z / perColumn)

	for row = 1, perRow do
		for layer = 1, layers do
			for column = 1, perColumn do
				local box = template:Clone()

				box:PivotTo(CFrame.new(boxSize.X * (row - 1), boxSize.Y * (layer - 1), boxSize.Z * (column - 1)))
				box.Size = boxSize
				box.Parent = boxes
			end
		end
	end

	local boxesPosition, boxesSize = boxes:GetBoundingBox()

	local boxesTop = Instance.new("Part")
	boxesTop.Anchored = true
	boxesTop.CanCollide = false
	boxesTop.CFrame = boxesPosition + Vector3.new(0, boxesSize.Y / 2, 0)
	boxesTop.Size = Vector3.new(boxesSize.X, 0, boxesSize.Z)
	boxesTop.Transparency = 1
	boxesTop.Name = "BoxesTop"
	boxesTop.Parent = boxes

	return boxes
end

local function generateMap(template: Model, config: MapConfig): Model
	local map = template:Clone()
	local table = map.MatchTable
	local tableTop = table.TableTop

	local tableSizeY = tableTop.Size * Vector3.FromAxis(Enum.Axis.Y) / 2
	local boxRegion = Region3.new(
		(tableTop.Position - tableTop.Size / 2) + tableSizeY,
		(tableTop.Position + tableTop.Size / 2) + tableSizeY
	)

	local boxes = generateBoxes(boxRegion, config.boxConfig)
	boxes:PivotTo((tableTop.CFrame + ((tableTop.Size + boxes:GetExtentsSize()) / 2) * Vector3.FromAxis(Enum.Axis.Y)))
	boxes.Parent = table

	return map
end

-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ServerScriptService = game:GetService("ServerScriptService")

-- local generateMap = require(ServerScriptService.server.generateMap:Clone())

-- generateMap(ReplicatedStorage.maps.bedroom, {
-- 	boxConfig = {
-- 		perRow = 3,
-- 		perColumn = 3,
-- 		layers = 5,
-- 		boxHeight = 20,
-- 		template = ReplicatedStorage.maps.bedroomBox,
-- 	},
-- }).Parent = workspace

return generateMap
