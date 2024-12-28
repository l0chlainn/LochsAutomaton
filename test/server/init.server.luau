--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local LochsAutomaton = require(Packages:FindFirstChild("LochsAutomaton"))

local Machine = LochsAutomaton.Machine
local State = LochsAutomaton.State
local Transition = LochsAutomaton.Transition

local GREEN_STATUS = "green light, GO!"
local YELLOW_STATUS = "yellow light, SLOW DOWN!"
local RED_STATUS = "red light, STOP!"
local EMERGENCY_STATUS = "emergency! CALL SOMEONE!"

local status = RED_STATUS

local green = State.new("green")
green:bindAction("enter", function()
    status = GREEN_STATUS
end)

local yellow = State.new("yellow")
yellow:bindAction("enter", function()
    status = YELLOW_STATUS
end)

local red = State.new("red")
red:bindAction("enter", function()
    status = RED_STATUS
end)

local emergency = State.new("emergency")
emergency:bindAction("enter", function()
    status = EMERGENCY_STATUS
end)
emergency:bindAction("print", function(...)
    print(...)
end)

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
local freak = Transition.new(
    "freak",
    "emergency",
    {
        "green",
        "yellow",
        "red",
    },
    function(event, ...)
        print(event, ...)
        return true
    end
)

local lamp = Machine.new(
    "red",
    {
        green,
        yellow,
        red,
        emergency,
    },
    {
        go,
        yield,
        stop,
        freak,
    }
)

for _, event in {"go", "slow", "stop", "freak"} do
    print(`triggering event '{event}'`)
    lamp:triggerEvent(event)
    print(`active state: {lamp.state}, status is '{status}'`)
end
lamp:executeAction("print", "Hello, World!")
