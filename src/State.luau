--!strict

type callback = () -> ()

type StateClass = {
    __index: StateClass,

    is: (value: any) -> boolean,
    new: (name: string) -> State,

    bindAction: (self: State, action: string, callback: callback) -> (),
    unindAction: (self: State, action: string) -> (),

    enter: (self: State) -> (),
    exit: (self: State) -> (),
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
        error("name must be a string!", 2)
    end

    return setmetatable({
        name = name,
        _actionBindMap = {},
    }, State)
end

function State.bindAction(self: State, action: string, callback: callback): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    elseif type(action) ~= "string" then
        error("action must be a string!", 2)
    elseif type(callback) ~= "function" then
        error("callback must be a function!", 2)
    end

    self._actionBindMap[action] = callback
end

function State.unindAction(self: State, action: string): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    elseif type(action) ~= "string" then
        error("action must be a string!", 2)
    end

    self._actionBindMap[action] = nil
end

function State.enter(self: State): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    end

    local enterCallback = self._actionBindMap["enter"]
    if enterCallback then
        enterCallback()
    end
end

function State.exit(self: State): ()
    if not State.is(self) then
        error("self must be a State!", 2)
    end

    local exitCallback = self._actionBindMap["exit"]
    if exitCallback then
        exitCallback()
    end
end

return State
