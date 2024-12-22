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

local status = RED_STATUS

local green = State.new("green")
green:bindAction("enter", function()
    status = GREEN_STATUS
end)
green:bindAction("print", function(...)
    print(...)
end)

local yellow = State.new("yellow")
yellow:bindAction("enter", function()
    status = YELLOW_STATUS
end)

local red = State.new("red")
red:bindAction("enter", function()
    status = RED_STATUS
end)

local go = Transition.new("go", "green", {"red"})
local yield = Transition.new("slow", "yellow", {"green"})
local stop = Transition.new("stop", "red", {"yellow"})
local freak = Transition.new("freak", "emergency", {"green", "yellow", "red"})
freak:bindCondition("canFreak", function(event, ...)
    print(event, ...)
    return true
end)

local lamp = Machine.new("red", {
    green,
    yellow,
    red,
}, {
    go,
    yield,
    stop,
})

print(`initial state: {lamp.state}, status is '{status}'`)
lamp:executeAction("print", "Hello, World!", 123)
for _, event in {"stop", "go", "slow", "stop", "freak"} do
    print(`triggering event '{event}'`)
    lamp:triggerEvent(event)
    print(`active state: {lamp.state}, status is '{status}'`)
end
