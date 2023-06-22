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

-- boxes don't actually get generated in this fill region, they just automatically size based on it. should update this later to actually use the fill region.
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

	return boxes
end

local function generateMap(template: Model, config: MapConfig): Model
	local map = template:Clone()
	local table = map.MatchTable
	local tableTop = table.TableTop

	local boxRegion =
		Region3.new(tableTop.Position, tableTop.Position + Vector3.new(tableTop.Size.X, 0, tableTop.Size.Z))

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
