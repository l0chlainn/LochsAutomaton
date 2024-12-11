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
local green = State.new("green", {
    enter = function()
        status = GREEN_STATUS
    end,
})
local yellow = State.new("yellow", {
    enter = function()
        status = YELLOW_STATUS
    end,
})
local red = State.new("red", {
    enter = function()
        status = RED_STATUS
    end,
    foo = function(a, b, c)
        print(a, b, c)
    end
})

local go = Transition.new("go", "green", {"red"})
local yield = Transition.new("slow", "yellow", {"green"})
local stop = Transition.new("stop", "red", {"yellow"})

local lamp = Machine.new(
    "red",
    {green, yellow, red,},
    {go, yield, stop,}
)

print(`initial state: {lamp.state}, status is '{status}'`)
for _, event in {"go", "slow", "stop", "slow", "FOOBAR!"} do
    print(`triggering event '{event}'`)
    lamp:triggerEvent(event)
    print(`active state: {lamp.state}, status is '{status}'`)
end
lamp:performAction("foo", 123, "abc", {})
