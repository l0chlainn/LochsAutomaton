--!strict

type conditionCallback = (event: string, ...any) -> boolean

type TransitionClass = {
    __index: TransitionClass,

    is: (value: any) -> boolean,
    new: (event: string, toState: string, fromStates: {string}) -> Transition,

    bindCondition: (self: Transition, condition: string, callback: conditionCallback) -> (),
    unbindCondition: (self: Transition, condition: string) -> (),

    canTransition: (self: Transition, fromState: string, ...any) -> boolean,    
}
export type Transition = typeof(setmetatable({} :: {
    event: string,
    toState: string,
    fromStates: {string},

    _conditionBindMap: {[string]: conditionCallback?},
}, {} :: TransitionClass))

--[ Transition Class ]--
local Transition = {} :: TransitionClass
Transition.__index = Transition

function Transition.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == Transition
end

function Transition.new(event: string, toState: string, fromStates: {string}): Transition
    if type(event) ~= "string" then
        error("event must be a string!", 2)
    elseif type(toState) ~= "string" then
        error("toState must be a string!", 2)
    elseif type(fromStates) ~= "table" then
        error("fromStates must be a table!", 2)
    end

    return setmetatable({
        event = event,
        toState = toState,
        fromStates = fromStates,

        _conditionBindMap = {},
    }, Transition)
end

function Transition.bindCondition(self: Transition, condition: string, callback: conditionCallback): ()
    if not Transition.is(self) then
        error("self must be a Transition!", 2)
    elseif type(condition) ~= "string" then
        error("condition must be a string!", 2)
    elseif type(callback) ~= "function" then
        error("callback must be a function!", 2)
    end

    self._conditionBindMap[condition] = callback
end

function Transition.unbindCondition(self: Transition, condition: string): ()
    if not Transition.is(self) then
        error("self must be a Transition!", 2)
    elseif type(condition) ~= "string" then
        error("condition must be a string!", 2)
    end

    self._conditionBindMap[condition] = nil
end

function Transition.canTransition(self: Transition, fromState: string, ...: any): boolean
    if not Transition.is(self) then
        error("self must be a Transition!", 2)
    elseif type(fromState) ~= "string" then
        error("fromState must be a string!", 2)
    end

    if not table.find(self.fromStates, fromState) then
        return false
    end

    local event = self.event
    for _, callback in self._conditionBindMap :: {[string]: conditionCallback} do
        if not callback(event, ...) then
            return false
        end
    end
    return true
end

return Transition
