local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

local MapVoteUi = require(script.MapVoteUi)

local function Root(props)
    local RootUi = New("Frame")({
        BackgroundTransparency = 1,
        Name = "Root",
        Size = UDim2.fromScale(1, 1),

        [Children] = {
            MapVoteUi({
                mapVotes = {
                    {
                        image = "rbxtemp://1",
                        mapName = "bedroom"
                    },
                    {
                        image = "rbxtemp://1",
                        mapName = "map2"
                    }
                }
            }),
        }
    })

    return RootUi
end

return Root