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

---@param from number
---@param to number
---@param step? number
---@return Iter
function M.iter_range(from, to, step)
    step = step or 1
    local i = from - step
    if step < 0 then
        return vim.iter(function()
            i = i + step
            if i < to then
                return nil
            else
                return i
            end
        end)
    else
        return vim.iter(function()
            i = i + step
            if to < i then
                return nil
            else
                return i
            end
        end)
    end
end

return M
