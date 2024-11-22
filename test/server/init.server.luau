--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local LochsAutomaton = require(Packages:FindFirstChild("LochsAutomaton"))

local Machine = LochsAutomaton.Machine
local State = LochsAutomaton.State
local Transition = LochsAutomaton.Transition

local lightStatus = "Red Light!"

local greenState = State.new("green")
greenState:bindAction("enter", function()
    lightStatus = "Green light, GO!"
end)

local yellowState = State.new("yellow")
yellowState:bindAction("enter", function()
    lightStatus = "Yellow light, YIELD!"
end)

local redState = State.new("red")
redState:bindAction("enter", function()
    lightStatus = "Red light, STOP!"
end)

local goTransition = Transition.new("go", "green", {"red"})
local yieldTransition = Transition.new("yield", "yellow", {"green"})
local stopTransition = Transition.new("stop", "red", {"yellow"})
stopTransition:bindCondition("emergency", function(event, a, b)
    print(event, a, b)
    return true
end)

local trafficLight = Machine.new("red", {
    greenState,
    yellowState,
    redState,
}, {
    goTransition,
    yieldTransition,
    stopTransition,
})

print("Initial: ", "Machine State: ", trafficLight.state, "Light status: ", lightStatus)

print("Triggering 'go' event...")
trafficLight:triggerEvent("go")
print("Machine State: ", trafficLight.state, "Light status: ", lightStatus)

print("Triggering 'yield' event...")
trafficLight:triggerEvent("yield")
print("Machine State: ", trafficLight.state, "Light status: ", lightStatus)

print("Triggering 'stop' event...")
trafficLight:triggerEvent("stop")
print("Machine State: ", trafficLight.state, "Light status: ", lightStatus)

print("Triggering 'yield' event...")
trafficLight:triggerEvent("yield")
print("Machine State: ", trafficLight.state, "Light status: ", lightStatus)
