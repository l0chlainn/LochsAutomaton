--!strict

type callback = (...any) -> boolean

type TransitionClass = {
    __index: TransitionClass,

    is: (value: any) -> boolean,
    new: (
        event: string,
        toState: string,
        fromStates: {string},
        condition: callback?
    ) -> Transition,

    canTransition: (self: Transition, fromState: string, ...any) -> boolean,
}
export type Transition = typeof(setmetatable({} :: {
    event: string,
    toState: string,
    fromStates: {string},
    _condition: callback?,
}, {} :: TransitionClass))

--[ Transition Class ]--
local Transition = {} :: TransitionClass
Transition.__index = Transition

function Transition.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == Transition
end

function Transition.new(
    event: string,
    toState: string,
    fromStates: {string},
    callback: callback?
): Transition
    if type(event) ~= "string" then
        error(`expected string for event, got '{typeof(event)}'`, 2)
    elseif type(toState) ~= "string" then
        error(`expected string for toState, got '{typeof(toState)}'`, 2)
    elseif type(fromStates) ~= "table" then
        error(`expected table for fromStates, got '{typeof(fromStates)}'`, 2)
    elseif callback ~= nil and type(callback) ~= "function" then
        error(`expected function for callback, got '{typeof(callback)}'`, 2)
    end

    return setmetatable({
        event = event,
        toState = toState,
        fromStates = fromStates,
        _condition = callback,
    }, Transition)
end

function Transition.canTransition(self: Transition, fromState: string, ...: any): boolean
    if not Transition.is(self) then
        error(`expected Transition for self, got '{typeof(self)}'`, 2)
    elseif type(fromState) ~= "string" then
        error(`expected string for fromState, got '{typeof(fromState)}'`, 2)
    end

    if table.find(self.fromStates, fromState) then
        local condition = self._condition
        if not condition or condition(...) then
            return true
        end
    end
    return false
end

return Transition
