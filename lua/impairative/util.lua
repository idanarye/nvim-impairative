local M = {}

---@class ImpairativeJumpTarget
---@field filename? string
---@field lnum? integer
---@field col? integer
local ImpairativeJumpTarget

---@param target ImpairativeJumpTarget
function M.jump_to(target)
    if target.filename then
        local bufnr = vim.fn.bufnr(target.filename, true)
        vim.api.nvim_set_current_buf(bufnr)
    end
    if target.lnum then
        vim.api.nvim_win_set_cursor(0, {target.lnum, (target.col or 1) - 1})
    end
end

return M
