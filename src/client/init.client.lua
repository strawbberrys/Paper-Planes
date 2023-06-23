local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage.packages
local Fusion = require(packages.Fusion)
local Knit = require(packages.Knit)
Knit.AddControllers(script.controllers)
Knit.Start():catch(warn):await()

local New, Children = Fusion.New, Fusion.Children
local Root = require(script.components.Root)

New("ScreenGui")({
	Name = "App",
	IgnoreGuiInset = true,
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),

	[Children] = Root({}),
})

print("Client started")
