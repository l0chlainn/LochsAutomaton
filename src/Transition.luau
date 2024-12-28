--!strict

type condition = (event: string, ...any) -> boolean

type TransitionClass = {
    __index: TransitionClass,

    is: (value: any) -> boolean,
    new: (
        event: string,
        to: string,
        from: {string},
        condition: condition?
    ) -> Transition,

    canTransition: (
        self: Transition,
        from: string,
        event: string,
        ...any
    ) -> boolean,
}
export type Transition = typeof(setmetatable({} :: {
    event: string,
    to: string,
    from: {string},
    _condition: condition?,
}, {} :: TransitionClass))

--[ Transition Class ]--
local Transition = {} :: TransitionClass
Transition.__index = Transition

function Transition.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == Transition
end

function Transition.new(
    event: string,
    to: string,
    from: {string},
    condition: condition?
): Transition
    if type(event) ~= "string" then
    error(`expected string for event, got '{typeof(event)}'`, 2)
    elseif type(to) ~= "string" then
        error(`expected string for to, got '{typeof(to)}'`, 2)
    elseif type(from) ~= "table" then
        error(`expected table for from, got '{typeof(from)}'`, 2)
    elseif condition ~= nil and type(condition) ~= "function" then
        error(`expected function for condition, got '{typeof(condition)}'`, 2)
    end

    return setmetatable({
        event = event,
        to = to,
        from = from,
        _condition = condition,
    }, Transition)
end

function Transition.canTransition(
    self: Transition,
    from: string,
    event: string,
    ...: any
): boolean
    if not Transition.is(self) then
        error(`expected Transition for self, got '{typeof(self)}'`, 2)
    elseif type(from) ~= "string" then
        error(`expected string for from, got '{typeof(from)}'`, 2)
    elseif type(event) ~= "string" then
        error(`expected string for event, got '{typeof(event)}'`, 2)
    end

    if table.find(self.from, from) then
        local condition = self._condition
        if not condition or condition(event, ...) then
            return true
        end
    end
    return false
end

return Transition
