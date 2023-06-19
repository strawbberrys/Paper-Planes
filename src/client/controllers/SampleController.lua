local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.knit)

local SampleController = Knit.CreateController({ Name = "SampleController " })

return SampleController
