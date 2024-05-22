local M = {}

local function reverse_in_place(table)
    local len = #table
    for i = 1, len / 2 do
        local j = len + 1 - i
        local tmp = table[i]
        table[i] = table[j]
        table[j] = tmp
    end
end

---@param start_from string
---@param backwards? boolean
---@return Iter
function M.walk_files_tree(start_from, backwards)
    local get_neighbors
    if backwards then
        function get_neighbors(for_path)
            local basename = vim.fs.basename(for_path)
            local result = {}
            local len = 1
            for name, node_type in vim.fs.dir(vim.fs.dirname(for_path)) do
                if name == basename then
                    break
                else
                    len = len + 1
                    result[len] = {name, node_type}
                end
            end
            reverse_in_place(result)
            return result
        end
    else
        function get_neighbors(for_path)
            local basename = vim.fs.basename(for_path)
            local result
            local len
            for name, node_type in vim.fs.dir(vim.fs.dirname(for_path)) do
                if name == basename then
                    result = {}
                    len = 0
                elseif result then
                    len = len + 1
                    result[len] = {name, node_type}
                end
            end
            return result or {}
        end
    end

    local stack = {}
    -- start_from = vim.fn.fnamemodify(start_from, ':p')
    for path in vim.fs.parents(start_from) do
        table.insert(stack, path)
    end
    table.remove(stack)
    reverse_in_place(stack)
    if vim.fn.isdirectory(start_from) == 0 then
        table.insert(stack, start_from)
    end

    local function expand_stack_head_if_needed()
        local head_idx = #stack
        if type(stack[head_idx]) == 'table' then
            return
        end
        local dirname = vim.fs.dirname(stack[head_idx])
        local new_head = get_neighbors(stack[head_idx])
        new_head.dirname = dirname
        new_head.cursor = 0
        stack[head_idx] = new_head
    end

    return vim.iter(function()
        while next(stack) ~= nil do
            expand_stack_head_if_needed()
            local head = stack[#stack]
            head.cursor = head.cursor + 1
            local entry = head[head.cursor]
            if not entry then
                table.remove(stack)
            elseif entry[2] == 'directory' then
                table.insert(stack, vim.fs.joinpath(head.dirname, entry[1]))
            else
                return vim.fs.joinpath(head.dirname, entry[1])
            end
        end
    end)
end

return M
