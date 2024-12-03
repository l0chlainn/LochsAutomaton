--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local LochsAutomaton = require(Packages:FindFirstChild("LochsAutomaton"))

local Machine = LochsAutomaton.Machine
local State = LochsAutomaton.State
local Transition = LochsAutomaton.Transition

local lightStatus = "Red Light!"

local greenState = State.new("green")
greenState:bindToEnter("enter", function()
    lightStatus = "green light!"
end)

local yellowState = State.new("yellow")
yellowState:bindToEnter("enter", function()
    lightStatus = "yellow light!"
end)

local redState = State.new("red")
redState:bindToEnter("enter", function()
    lightStatus = "red light!"
end)

local goTransition = Transition.new("go", "green", {"red"})
local yieldTransition = Transition.new("yield", "yellow", {"green"})
local stopTransition = Transition.new("stop", "red", {"yellow"})

local trafficLight = Machine.new("red", {
    greenState,
    yellowState,
    redState,
}, {
    goTransition,
    yieldTransition,
    stopTransition,
})

print(`initial: {trafficLight.state}, light status is '{lightStatus}'`)
for _, event in {"go", "yield", "stop", "yield"} do
    print(`processing '{event}' event...`)
    local success = trafficLight:tryTransition(event)
    if success then
        print(`transitioned to '{trafficLight.state}', light status is '{lightStatus}'`)
    else
        print(`failed to transition! state remains {trafficLight.state}`)
    end
end
