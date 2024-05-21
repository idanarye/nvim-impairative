---@mod impairative Impairative - Pairs of complementing keybinds
local M = {}

---Doesn't do anything, but some plugins managers expect all plugins to have one.
function M.setup()
end

---@param opts ImpairativeTogglingOptions
---@return ImpairativeToggling
function M.toggling(opts)
    return setmetatable({
        _opts = opts,
    }, {
        __index = require'impairative.toggling',
    })
end

---@param opts ImpairativeOperationsOptions
---@return ImpairativeOperations
function M.operations(opts)
    return setmetatable({
        _opts = opts,
    }, {
        __index = require'impairative.operations',
    })
end

return M
