--!strict

type actionCallback = () -> ()

type StateClass = {
    __index: StateClass,

    is: (value: any) -> boolean,
    new: (name: string) -> State,

    bindToEnter: (self: State, name: string, callback: actionCallback) -> (),
    unindFromEnter: (self: State, name: string) -> (),

    bindToExit: (self: State, name: string, callback: actionCallback) -> (),
    unindFromExit: (self: State, name: string) -> (),

    enter: (self: State) -> (),
    exit: (self: State) -> (),
}
export type State = typeof(setmetatable({} :: {
    name: string,
    _enterBindMap: {[string]: actionCallback},
    _exitBindMap: {[string]: actionCallback},
}, {} :: StateClass))

--[ State Class ]--
local State = {} :: StateClass
State.__index = State

function State.is(value: any): boolean
    return type(value) == "table" and getmetatable(value) == State
end

function State.new(name: string): State
    if type(name) ~= "string" then
        error("name must be a string!", 2)
    end

    return setmetatable({
        name = name,
        _enterBindMap = {},
        _exitBindMap = {},
    }, State)
end

function State.bindToEnter(self: State, name: string, callback: actionCallback): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    elseif type(name) ~= "string" then
        error("name must be a string!", 2)
    elseif type(callback) ~= "function" then
        error("callback must be a function!", 2)
    end

    self._enterBindMap[name] = callback
end

function State.unindFromEnter(self: State, name: string): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    elseif type(name) ~= "string" then
        error("name must be a string!", 2)
    end

    self._enterBindMap[name] = nil
end

function State.bindToExit(self: State, name: string, callback: actionCallback): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    elseif type(name) ~= "string" then
        error("name must be a string!", 2)
    elseif type(callback) ~= "function" then
        error("callback must be a function!", 2)
    end

    self._exitBindMap[name] = callback
end

function State.unindFromExit(self: State, name: string): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    elseif type(name) ~= "string" then
        error("name must be a string!", 2)
    end

    self._exitBindMap[name] = nil
end

function State.enter(self: State): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    end

    for _, enterCallback in self._enterBindMap do
        enterCallback()
    end
end

function State.exit(self: State): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    end

    for _, exitCallback in self._exitBindMap do
        exitCallback()
    end
end

return State
