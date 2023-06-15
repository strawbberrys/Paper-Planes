export type MapConfig = {
    boxConfig: {
        perRow: number,
        perColumn: number,
        layers: number,
        template: Model,
    }
}

local function generateBoxes(fillRegion: Region3, perRow: number, perColumn: number, layers: number, template: Model): Model
    local boxes = Instance.new("Model")
    boxes.Name = "Boxes"

    local boxSize = Vector3.new(
        fillRegion.Size.X / perRow,
        fillRegion.Size.Y / layers,
        fillRegion.Size.Z / perColumn
    )

    for row = 1, perRow do
        for layer = 1, layers do
            for column = 1, perColumn do
                local box = template:Clone()

                box:PivotTo(fillRegion.CFrame * CFrame.new(boxSize.X * (row - 1)), boxSize.Y * (layer - 1), boxSize.Z * (column - 1)) 
                box.Size = boxSize
                box.Parent = boxes
            end
        end
    end

    return boxes
end

local function generateMap(tempalte: Model, config: MapConfig): Model
    local map = tempalte:Clone()
    local table = map.MatchTable
    local tableTop = table.TableTop

    local boxConfig = config.boxConfig

    local boxRegion = Region3.new(
        tableTop.Position,
        tableTop.Position + Vector3.new(tableTop.Size.X, 0, tableTop.Size.Z)
    )

    local boxes = generateBoxes(boxRegion, boxConfig.perRow, boxConfig.perColumn, boxConfig.layers, boxConfig.template)
    boxes.Parent = table

    return map
end

return generateMap
