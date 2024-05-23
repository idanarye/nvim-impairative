---@class ImpairativeOperationsOptions
---@field backward string Leader keys for turning the operation backward
---@field forward string Leader keys for running the operation forward
local ImpairativeOperationsOptions

---@class ImpairativeOperations
---@field _opts ImpairativeOperationsOptions
local ImpairativeOperations = {}

---@class ImpairativeOperationsFunctionPairArgs
---@field key string
---@field desc? string
---@field backward fun()
---@field forward fun()
local ImpairativeOperationsFunctionPairArgs

---@param args ImpairativeOperationsFunctionPairArgs
---@return ImpairativeOperations
function ImpairativeOperations:function_pair(args)
    local function gen_opts(i)
        if args.desc then
            return {
                desc = args.desc:gsub("{(.-)}", function(m)
                    local parts = vim.split(m, '|', {plain = true})
                    if #parts == 2 then
                        return parts[i]
                    end
                end),
            }
        end
    end
    vim.keymap.set('n', self._opts.backward .. args.key, args.backward, gen_opts(1))
    vim.keymap.set('n', self._opts.forward .. args.key, args.forward, gen_opts(2))
    return self
end

---@class ImpairativeOperationsUnifiedFunctionArgs
---@field key string
---@field desc? string
---@field fun fun(direction: 'backward'|'forward')
local ImpairativeOperationsUnifiedFunctionArgs

---@param args ImpairativeOperationsUnifiedFunctionArgs
---@return ImpairativeOperations
function ImpairativeOperations:unified_function(args)
    return self:function_pair {
        key = args.key,
        desc = args.desc,
        backward = function()
            return args.fun('backward')
        end,
        forward = function()
            return args.fun('forward')
        end,
    }
end

---@class ImpairativeOperationsCommandPairArgs
---@field key string
---@field backward string
---@field forward string
local ImpairativeOperationsCommandPairArgs

---@param args ImpairativeOperationsCommandPairArgs
---@return ImpairativeOperations
function ImpairativeOperations:command_pair(args)
    vim.keymap.set('n', self._opts.backward .. args.key, '<Cmd>' .. args.backward .. '<Cr>')
    vim.keymap.set('n', self._opts.forward .. args.key, '<Cmd>' .. args.forward .. '<Cr>')
    return self
end

---@class ImpairativeRangeOp
---@field direction 'backward'|'forward'
---@field count integer
---@field range_type string
---@field start_line integer
---@field end_line integer
---@field start_col integer
---@field end_col integer
local ImpairativeRangeOp

---@class ImpairativeOperationRangeManipulationArgs
---@field key string
---@field line_key? string|boolean
---@field desc? string
---@field fun fun(args: ImpairativeRangeOp)
local ImpairativeOperationRangeManipulationArgs

---@param args ImpairativeOperationRangeManipulationArgs
function ImpairativeOperations:range_manipulation(args)
    local line_key
    if args.line_key == true then
        line_key = args.key
    elseif args.line_key then
        line_key = args.line_key
    end
    for _, direction in ipairs{'backward', 'forward'} do
        local function set_operator_func()
            local count = vim.v.count
            require'impairative._operator_func'.operatorfunc = function(range_type)
                local region_start = vim.fn.getpos("'[")
                local region_end = vim.fn.getpos("']")

                args.fun {
                    direction = direction,
                    count = count,
                    range_type = range_type,
                    start_line = region_start[2],
                    start_col = region_start[3],
                    end_line = region_end[2],
                    end_col = region_end[3],
                }
            end
            vim.o.operatorfunc = "v:lua.require'impairative._operator_func'.operatorfunc"
        end
        vim.keymap.set({'n', 'x'}, self._opts[direction] .. args.key, function()
            set_operator_func()
            vim.api.nvim_feedkeys('g@', 'ni', false)
        end)
        if line_key then
            vim.keymap.set('n', self._opts[direction] .. args.key .. line_key, function()
                set_operator_func()
                vim.api.nvim_feedkeys('Vg@', 'ni', false)
            end)
        end
    end
    return self
end

---@class ImpairativeOperationsTextManipulationArgs
---@field key string
---@field line_key? string|boolean
---@field desc? string
---@field backward fun(orig: string): string
---@field forward fun(orig: string): string
local ImpairativeOperationsTextManipulationArgs

---@param args ImpairativeOperationsTextManipulationArgs
---@return ImpairativeOperations
function ImpairativeOperations:text_manipulation(args)
    return self:range_manipulation {
        key = args.key,
        line_key = args.key,
        desc = args.desc,
        fun = function(op)
            local function change_lines(orig_lines)
                local orig_text = table.concat(orig_lines, '\n')
                local new_text = args[op.direction](orig_text)
                return vim.split(new_text, '\n', {plain = true})
            end

            if op.range_type == 'char' then
                local orig_lines = vim.api.nvim_buf_get_text(0, op.start_line - 1, op.start_col - 1, op.end_line - 1, op.end_col, {})
                vim.api.nvim_buf_set_text(0, op.start_line - 1, op.start_col - 1, op.end_line - 1, op.end_col, change_lines(orig_lines))
            elseif op.range_type == 'line' then
                local orig_lines = vim.api.nvim_buf_get_lines(0, op.start_line - 1, op.end_line, true)
                vim.api.nvim_buf_set_lines(0, op.start_line - 1, op.end_line, true, change_lines(orig_lines))
            elseif op.range_type == 'block' then
                for line = op.end_line, op.start_line, -1 do
                    local orig_lines = vim.api.nvim_buf_get_text(0, line - 1, op.start_col - 1, line - 1, op.end_col, {})
                    vim.api.nvim_buf_set_text(0, line - 1, op.start_col - 1, line - 1, op.end_col, change_lines(orig_lines))
                end
            else
                error("Unsupported range type " .. vim.inspect(op.range_type))
            end
        end,
    }
end

return ImpairativeOperations
