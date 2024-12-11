--!strict

type callback = () -> ()

type StateClass = {
    __index: StateClass,

    is: (value: any) -> boolean,
    new: (name: string) -> State,

    bindAction: (self: State, name: string, callback: callback) -> (),
    unbindAction: (self: State, name: string) -> (),

    performAction: (self: State, name: string, ...any) -> (),
}
export type State = typeof(setmetatable({} :: {
    name: string,
    _actionBindMap: {[string]: callback?},
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
        _actionBindMap = {},
    }, State)
end

function State.bindAction(self: State, name: string, callback: callback): ()
    if not State.is(self) then
        error(`expected State for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    elseif type(callback) ~= "function" then
        error(`expected function for callback, got '{typeof(callback)}'`, 2)
    end

    self._actionBindMap[name] = callback
end

function State.unbindAction(self: State, name: string): ()
    if not State.is(self) then
        error(`expected State for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    self._actionBindMap[name] = nil
end

function State.performAction(self: State, name: string, ...: any): ()
    if not State.is(self) then
        error(`expected State for self, got '{typeof(self)}'`, 2)
    elseif type(name) ~= "string" then
        error(`expected string for name, got '{typeof(name)}'`, 2)
    end

    local action = self._actionBindMap[name]
    if action then
        action(...)
    end
end

return State
