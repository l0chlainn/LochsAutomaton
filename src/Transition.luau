--!strict

type TransitionClass = {
    __index: TransitionClass,

    is: (value: any) -> boolean,
    new: (event: string, toState: string, fromStates: {string}) -> Transition,

    canTransition: (self: Transition, fromState: string, ...any) -> boolean,
}
export type Transition = typeof(setmetatable({} :: {
    event: string,
    toState: string,
    fromStates: {string},
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
    }, Transition)
end

function Transition.canTransition(self: Transition, fromState: string, ...: any): boolean
    if not Transition.is(self) then
        error("self must be a Transition!", 2)
    elseif type(fromState) ~= "string" then
        error("fromState must be a string!", 2)
    end

    return table.find(self.fromStates, fromState) ~= nil
end

return Transition
