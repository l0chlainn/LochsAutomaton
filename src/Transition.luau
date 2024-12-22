--!strict

type conditionCallback = (event: string, ...any) -> boolean

type TransitionClass = {
    __index: TransitionClass,

    is: (value: any) -> boolean,
    new: (event: string, toState: string, fromStates: {string}) -> Transition,

    bindCondition: (self: Transition, name: string, callback: conditionCallback) -> (),
    unbindCondition: (self: Transition, name: string) -> (),
    canTransition: (
        self: Transition,
        fromState: string,
        event: string,
        ...any
    ) -> boolean,
}
export type Transition = typeof(setmetatable({} :: {
    event: string,
    toState: string,
    fromStates: {string},
    _conditionMap: {[string]: conditionCallback},
}, {} :: TransitionClass))

--[ Transition Class ]--
local Transition = {} :: TransitionClass
Transition.__index = Transition

function Transition.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == Transition
end

function Transition.new(event: string, toState: string, fromStates: {string}): Transition
    if type(event) ~= "string" then
        error(`expected string for event, got '{typeof(event)}'`, 2)
    elseif type(toState) ~= "string" then
        error(`expected string for toState, got '{typeof(toState)}'`, 2)
    elseif type(fromStates) ~= "table" then
        error(`expected table for fromStates, got '{typeof(fromStates)}'`, 2)
    end

    return setmetatable({
        event = event,
        toState = toState,
        fromStates = fromStates,
        _conditionMap = {},
    }, Transition)
end

function Transition.bindCondition(self: Transition, name: string, callback: conditionCallback): ()
    if not Transition.is(self) then
        error(`expected Transition for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    elseif type(callback) ~= "function" then
        error(`expected function for callback, got '{typeof(callback)}'`, 2)
    end

    self._conditionMap[name] = callback
end

function Transition.unbindCondition(self: Transition, name: string): ()
    if not Transition.is(self) then
        error(`expected Transition for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    self._conditionMap[name] = nil
end

function Transition.canTransition(
    self: Transition,
    fromState: string,
    event: string,
    ...: any
): boolean
    if not Transition.is(self) then
        error(`expected Transition for self, got '{typeof(self)}'`, 2)
    elseif type(fromState) ~= "string" then
        error(`expected string for fromState, got '{typeof(fromState)}'`, 2)
    elseif type(event) ~= "string" then
        error(`expected string for event, got '{typeof(event)}'`, 2)
    end

    if not table.find(self.fromStates, fromState) then
        return false
    end

    for _, condition in self._conditionMap do
        if not condition(event, ...) then
            return false
        end
    end
    return true
end

return Transition
