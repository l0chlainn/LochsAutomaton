--!strict

local Machine = require(script:FindFirstChild("Machine"))
local State = require(script:FindFirstChild("State"))
local Transition = require(script:FindFirstChild("Transition"))

type MachineClass = typeof(Machine)
type StateClass = typeof(State)
type TransitionClass = typeof(Transition)

type LochsAutomatonLibrary = {
    Machine: MachineClass,
    State: StateClass,
    Transition: TransitionClass,
}

--[ LochsAutomaton Library ]--
local LochsAutomaton: LochsAutomatonLibrary = {
    Machine = Machine,
    State = State,
    Transition = Transition,
}

return LochsAutomaton
