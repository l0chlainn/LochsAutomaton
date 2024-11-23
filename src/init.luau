--!strict

local Machine = require(script:FindFirstChild("Machine"))
local State = require(script:FindFirstChild("State"))
local Transition = require(script:FindFirstChild("Transition"))

type MachineClass = typeof(Machine)
export type Machine = Machine.Machine

type StateClass = typeof(State)
export type State = State.State

type TransitionClass = typeof(Transition)
export type Transition = Transition.Transition

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
