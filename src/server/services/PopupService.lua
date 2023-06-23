-- will create a popup ui on the users client
-- will have a PopupConfig argument
--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.Knit)
local Promise = require(packages.Promise)

local PopupService = Knit.CreateService({
	Name = "PopupService",

	Client = {},
})

function PopupService:sendPopup() end

return PopupService
