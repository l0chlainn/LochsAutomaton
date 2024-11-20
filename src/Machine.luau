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
}
export type Machine = typeof(setmetatable({} :: {
    state: string,

    _stateMap: {[string]: State?},
    _eventTransitionsMap: {[string]: {Transition}?},

    stateChanged: Signal,
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
            error(`index '{index}' in states must be a State!`, 2)
        end

        stateMap[state.name] = state
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

    if not stateMap[initial] then
        error("initial does not map to a State!", 2)
    end

    return setmetatable({
        state = initial,

        _stateMap = stateMap,
        _eventTransitionsMap = eventTransitionsMap,

        stateChanged = Signal.new(),
    }, Machine)
end

function Machine.changeState(self: Machine, state: string): ()
    if not Machine.is(self) then
        error("self must be an Machine!", 2)
    elseif type(state) ~= "string" then
        error("state must be a string!", 2)
    end

    local futureState = self._stateMap[state]
    if not futureState then
        error(`'{state}' does not map to a State!`, 2)
    end

    local currentState = self._stateMap[self.state] :: State
    currentState:exit()
    futureState:enter()

    self.state = futureState.name
    self.stateChanged:trigger(currentState.name, futureState.name)
end

function Machine.triggerEvent(self: Machine, event: string, ...: any): ()
    if not Machine.is(self) then
        error("self must be an Machine!", 2)
    elseif type(event) ~= "string" then
        error("event must be a string!", 2)
    end

    local eventTransitions = self._eventTransitionsMap[event]
    if eventTransitions then
        local currentState = self.state
        for _, transition in eventTransitions do
            if transition:canTransition(currentState, ...) then
                self:changeState(transition.toState)
                break
            end
        end
    end
end

return Machine
