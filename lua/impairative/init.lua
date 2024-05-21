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

return M
