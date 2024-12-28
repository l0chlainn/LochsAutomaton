--!strict

type action = (...any) -> (...any)

type StateClass = {
    __index: StateClass,

    is: (value: any) -> boolean,
    new: (name: string) -> State,

    bindAction: (self: State, name: string, action: action) -> (),
    unbindAction: (self: State, name: string) -> (),
    executeAction: (self: State, name: string, ...any) -> ...any,
}
export type State = typeof(setmetatable({} :: {
    name: string,
    _actionMap: {[string]: action},
}, {} :: StateClass))

--[ State Class ]--
local State = {} :: StateClass
State.__index = State

function State.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == State
end

function State.new(name: string): State
    if type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    return setmetatable({
        name = name,
        _actionMap = {},
    }, State)
end

function State.bindAction(self: State, name: string, action: action): ()
    if not State.is(self) then
        error(`expected State for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    elseif type(action) ~= "function" then
        error(`expected function for action, got '{typeof(action)}'`, 2)
    end

    self._actionMap[name] = action
end

function State.unbindAction(self: State, name: string): ()
    if not State.is(self) then
        error(`expected State for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    self._actionMap[name] = nil
end

function State.executeAction(self: State, name: string, ...: any): ...any
    if not State.is(self) then
        error(`expected State for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    local action = self._actionMap[name]
    if action then
        return action(...)
    end
end

return State
