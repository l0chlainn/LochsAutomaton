--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local LochsKit = require(Packages:FindFirstChild("LochsKit"))

local Signal = LochsKit.Signal

local LochsAutomaton = script.Parent
local State = require(LochsAutomaton:FindFirstChild("State"))
local Transition = require(LochsAutomaton:FindFirstChild("Transition"))

type Signal = LochsKit.Signal

type State = State.State
type Transition = Transition.Transition

type MachineClass = {
    __index: MachineClass,

    is: (value: any) -> boolean,
    new: (initial: string, states: {State}, transitions: {Transition}) -> Machine,

    changeState: (self: Machine, state: string) -> (),
    triggerEvent: (self: Machine, event: string, ...any) -> (),
    executeAction: (self: Machine, name: string, ...any) -> ...any,
}
export type Machine = typeof(setmetatable({} :: {
    state: string,
    _stateMap: {[string]: State},
    _eventListenersMap: {[string]: {Transition}},

    onStateChanged: Signal,
}, {} :: MachineClass))

--[ Machine Class ]--
local Machine = {} :: MachineClass
Machine.__index = Machine

function Machine.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == Machine
end

function Machine.new(initial: string, states: {State}, transitions: {Transition}): Machine
    if type(initial) ~= "string" then
        error(`expected string for initial, got '{typeof(initial)}'`, 2)
    elseif type(states) ~= "table" then
        error(`expected table for states, got '{typeof(states)}'`, 2)
    elseif type(transitions) ~= "table" then
        error(`expected table for transitions, got '{typeof(transitions)}'`, 2)
    end

    local stateMap = {}
    for index, state in states do
        if not State.is(state) then
            error(`expected State for states[{index}], got '{typeof(state)}'`, 2)
        end

        stateMap[state.name] = state
    end

    local eventListenersMap = {}
    for index, transition in transitions do
        if not Transition.is(transition) then
            error(`expected Transition for transitions[{index}], got '{typeof(transition)}'`, 2)
        elseif not stateMap[transition.to] then
            error(`transitions[{index}].to '{transition.to}', does not map to a State!`, 2)
        end

        local eventListeners = eventListenersMap[transition.event]
        if eventListeners then
            table.insert(eventListeners, transition)
        else
            eventListenersMap[transition.event] = {transition}
        end
    end

    if not stateMap[initial] then
        error(`initial '{initial}', does not map to a State!`, 2)
    end

    return setmetatable({
        state = initial,
        _stateMap = stateMap,
        _eventListenersMap = eventListenersMap,

        onStateChanged = Signal.new(),
    }, Machine)
end

function Machine.changeState(self: Machine, state: string): ()
    if not Machine.is(self) then
        error(`expected Machine for self, got '{typeof(self)}'`, 2)
    elseif type(state) ~= "string" then
        error(`expected string for state, got '{typeof(state)}'`, 2)
    end

    local newState = self._stateMap[state] :: State?
    if not newState then
        error(`state '{state}', does not map to a State!`, 2)
    end

    local oldState = self._stateMap[self.state]
    oldState:executeAction("exit")
    newState:executeAction("enter")

    self.state = newState.name
    self.onStateChanged:trigger(oldState.name, newState.name)
end

function Machine.executeAction(self: Machine, name: string, ...: any): ...any
    if not Machine.is(self) then
        error(`expected Machine for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    local currentState = self._stateMap[self.state]
    return currentState:executeAction(name, ...)
end

function Machine.triggerEvent(self: Machine, event: string, ...: any): ()
    if not Machine.is(self) then
        error(`expected Machine for self, got '{typeof(self)}'`, 2)
    elseif type(event) ~= "string" then
        error(`expected string for event, got '{typeof(event)}'`, 2)
    end

    local eventListeners = self._eventListenersMap[event] :: {Transition}?
    if eventListeners then
        local state = self.state
        for _, transition in eventListeners do
            if transition:canTransition(state, event, ...) then
                self:changeState(transition.to)
                break
            end
        end
    end
end

return Machine
