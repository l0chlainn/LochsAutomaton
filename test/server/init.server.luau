--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local LochsAutomaton = require(Packages:FindFirstChild("LochsAutomaton"))

local Machine = LochsAutomaton.Machine
local State = LochsAutomaton.State
local Transition = LochsAutomaton.Transition

-- states
local green = State.new("green")
green:bindAction("enter", function()
    print("green light!")
end)
green:bindAction("move", function(speed)
    print(`you drove through the light, at {speed} MPH!`)
end)

local yellow = State.new("yellow")
yellow:bindAction("enter", function()
    print("yellow light!")
end)
yellow:bindAction("move", function(speed)
    print(`you approach the light, slowing from {speed} MPH!`)
end)

local red = State.new("red")
red:bindAction("enter", function()
    print("red light, STOP!")
end)
red:bindAction("move", function(speed)
    print(`you speed past the light, crashing at {speed} MPH!`)
end)

-- transitions
local go = Transition.new(
    "go",
    "green",
    {
        "red",
    }
)
local yield = Transition.new(
    "slow",
    "yellow",
    {
        "green",
    }
)
local stop = Transition.new(
    "stop",
    "red",
    {
        "yellow",
    }
)

-- machine
local lamp = Machine.new(
    "red",
    {
        green,
        yellow,
        red,
    },
    {
        go,
        yield,
        stop,
    }
)

-- testing
for _, event in {"go", "slow", "stop"} do
    print(`triggering event '{event}'...`)
    lamp:triggerEvent(event)
    lamp:executeAction("move", 50)
end
