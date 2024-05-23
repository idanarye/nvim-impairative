local M = {}

function M.operatorfunc(range_type)
    local region_start = vim.fn.getpos("'[")
    local region_end = vim.fn.getpos("']")

    M.action_on_range(range_type, region_start, region_end)
    if true then
        return
    end

    if range_type == 'char' then
        local orig_lines = vim.api.nvim_buf_get_text(
            region_start[1],
            region_start[2] - 1,
            region_start[3] - 1,
            region_end[2] - 1,
            region_end[3],
            {}
        )
        vim.api.nvim_buf_set_text(
            region_start[1],
            region_start[2] - 1,
            region_start[3] - 1,
            region_end[2] - 1,
            region_end[3],
            M.change_lines(orig_lines)
        )
    elseif range_type == 'line' then
        local orig_lines = vim.api.nvim_buf_get_lines(
            region_start[1],
            region_start[2] - 1,
            region_end[2],
            true
        )
        vim.api.nvim_buf_set_lines(
            region_start[1],
            region_start[2] - 1,
            region_end[2],
            true,
            M.change_lines(orig_lines)
        )
    elseif range_type == 'block' then
        vim.cmd.messages('clear')

        for line = region_end[2], region_start[2], -1 do
            local orig_lines = vim.api.nvim_buf_get_text(
                region_start[1],
                line - 1,
                region_start[3] - 1,
                line - 1,
                region_end[3],
                {}
            )
            vim.api.nvim_buf_set_text(
                region_start[1],
                line - 1,
                region_start[3] - 1,
                line - 1,
                region_end[3],
                M.change_lines(orig_lines)
            )
        end
    else
        error("Unsupported range type " .. vim.inspect(range_type))
    end
end

---@param range_type string
---@param range_start integer[]
---@param range_end integer[]
function M.action_on_range(range_type, range_start, range_end)
    error("`require'impairative._operator_func'.action_on_range` was not set")
end

---@param _ string
---@return string
function M.change_text(_)
    error("`require'impairative._operator_func'.change_text` was not set")
end

function M.change_lines(orig_lines)
    local orig_text = table.concat(orig_lines, '\n')
    local new_text = M.change_text(orig_text)
    return vim.split(new_text, '\n', {plain = true})
end

return M
