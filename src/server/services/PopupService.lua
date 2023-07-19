-- will create a popup ui on the users client
-- will have a PopupConfig argument
--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Knit = require(packages.Knit)
local Promise = require(packages.Promise)
local Signal = require(packages.Signal)

--[=[
	@class PopupService
	@tag Service
	@server

	A service that creates popups on the client.
]=]
local PopupService = Knit.CreateService({
	Name = "PopupService",

	totalPopups = 0,

	popupCreated = Signal.new(),

	Client = {
		popupCreated = Knit.CreateSignal(),
	},
})

--[=[
	@type PopupConfig { title: string, description: string, duration: number, }
	@within PopupService

	The popup configuration.
]=]
type PopupConfig = {
	title: string,
	description: string,
	recipients: { Player },
	duration: number,
}

--[=[
	@type PopupDetails = { title: string, description: string, duration: number, __identifier: number, }
	@within PopupService

	The popup details.
]=]
type PopupDetails = {
	title: string,
	description: string?,
	duration: number,
	__identifier: number,
}

--[=[
	Creates a popup and sends it to the [PopupConfig.recipients]. Popup will be removed automatically in [PopupConfig.duration] seconds.

	@param config -- help
	@return Promise.Promise -- Yields until the popup ends.
]=]
function PopupService:createPopup(config: PopupConfig): Promise.Promise
	self.totalPopups += 1

	local popupDetails = {
		title = config.title,
		description = config.description or "",
		duration = config.duration,
		__identifier = self.totalPopups,
	}

	self.popupCreated:Fire(popupDetails)
	self.Client.popupRemoved:FireFor(config.recipients, popupDetails)

	return Promise.delay(config.duration):andThen(function()
		self.Client.popupRemoved:FireFor(config.recipients, popupDetails.__identifier)
	end)
end

return PopupService
