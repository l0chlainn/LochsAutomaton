--!strict

type callback = (...any) -> ()

type StateClass = {
    __index: StateClass,

    is: (value: any) -> boolean,
    new: (name: string, actionMap: {[string]: callback}) -> State,

    performAction: (self: State, name: string, ...any) -> (),
}
export type State = typeof(setmetatable({} :: {
    name: string,
    _actionMap: {[string]: callback?},
}, {} :: StateClass))

--[ State Class ]--
local State = {} :: StateClass
State.__index = State

function State.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == State
end

function State.new(name: string, actionMap: {[string]: callback}): State
    if type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    elseif type(actionMap) ~= "table" then
        error(`expected table for actionMap, got '{typeof(actionMap)}'`, 2)
    end

    for key, callback in actionMap do
        if type(callback) ~= "function" then
            error(`expected function for actionMap[{key}], got '{typeof(callback)}'`, 2)
        end
    end

    return setmetatable({
        name = name,
        _actionMap = actionMap,
    }, State)
end

function State.performAction(self: State, name: string, ...: any): ()
    if not State.is(self) then
        error(`expected State for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    local action = self._actionMap[name]
    if action then
        action(...)
    end
end

return State
