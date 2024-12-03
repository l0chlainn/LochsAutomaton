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
    tryTransition: (self: Machine, event: string, ...any) -> boolean,
}
export type Machine = typeof(setmetatable({} :: {
    state: string,

    _stateMap: {[string]: State},
    _eventTransitionsMap: {[string]: {Transition}},

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
        error("initial must be a string!", 2)
    elseif type(states) ~= "table" then
        error("states must be a table!", 2)
    elseif type(transitions) ~= "table" then
        error("transitions must be a table!", 2)
    end

    local stateMap = {}
    for index, state in states do
        if not State.is(state) then
            error(`states[{index}] must be a State!`, 2)
        end

        stateMap[state.name] = state
    end

    if not stateMap[initial] then
        error("initial does not map to a State!", 2)
    end

    local eventTransitionsMap = {}
    for index, transition in transitions do
        if not Transition.is(transition) then
            error(`transitions[{index}] must be a Transition!`, 2)
        elseif not stateMap[transition.toState] then
            error(`transitions[{index}]'s toState does not map to a valid State!`, 2)
        end

        local eventTransitions = eventTransitionsMap[transition.event] :: {Transition}?
        if eventTransitions then
            table.insert(eventTransitions, transition)
        else
            eventTransitionsMap[transition.event] = {transition}
        end
    end

    return setmetatable({
        state = initial,

        _stateMap = stateMap,
        _eventTransitionsMap = eventTransitionsMap,

        onStateChanged = Signal.new(),
    }, Machine)
end

function Machine.changeState(self: Machine, state: string): ()
    if not Machine.is(self) then
        error("self must be an Machine!", 2)
    elseif type(state) ~= "string" then
        error("state must be a string!", 2)
    end

    local newState = self._stateMap[state] :: State?
    if not newState then
        error(`'{state}' does not map to a State!`, 2)
    end

    local currentState = self._stateMap[self.state]
    currentState:exit()
    newState:enter()

    self.state = newState.name
    self.onStateChanged:trigger(currentState.name, newState.name)
end

function Machine.tryTransition(self: Machine, event: string, ...: any): boolean
    if not Machine.is(self) then
        error("self must be an Machine!", 2)
    elseif type(event) ~= "string" then
        error("event must be a string!", 2)
    end

    local eventTransitions = self._eventTransitionsMap[event]
    if eventTransitions then
        local state = self.state
        for _, transition in eventTransitions do
            if transition:canTransition(state, ...) then
                self:changeState(transition.toState)
                return true
            end
        end
    end
    return false
end

return Machine
