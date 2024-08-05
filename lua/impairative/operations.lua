---@class ImpairativeOperationsOptions
---@field backward string Leader keys for turning the operation backward
---@field forward string Leader keys for running the operation forward
local ImpairativeOperationsOptions

---@class ImpairativeOperations
---@field _opts ImpairativeOperationsOptions
local ImpairativeOperations = {}

---Used to generate descriptions for the keymaps.
---
---There are two ways to specify the description:
---* A table with the backward and forward descriptions:
---  `{ backward = 'move backward', forward = 'move forward' }`
---* Template string:
---  `'move {backward|forward}'`
---@alias ImpairativeDesc string | {backward: string, forward: string}

local function validate_desc(desc)
    local desc_type = type(desc)
    if desc_type == 'table' then
        if type(desc.backward) ~= 'string' then
            return false, '`backward` is missing or not a string'
        end
        if type(desc.forward) ~= 'string' then
            return false, '`forward` is missing or not a string'
        end
        return true
    elseif desc then
        return desc_type == 'string'
    else
        return true
    end
end

---@param desc ImpairativeDesc
---@param i integer
local function process_desc(desc, i)
    if type(desc) == 'table' then
        return desc[({"backward", "forward"})[i]]
    elseif desc then
        vim.validate {
            desc = {desc, 'string'}
        }
        return desc:gsub("{(.-)}", function(m)
            local parts = vim.split(m, '|', {plain = true})
            if #parts == 2 then
                return parts[i]
            end
        end)
    end
end

---@class ImpairativeOperationsFunctionPairArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field desc? ImpairativeDesc see |ImpairativeDesc|
---@field backward fun() The "backward" operation
---@field forward fun() The "forward" operation
local ImpairativeOperationsFunctionPairArgs

---Bind operation mappings by directly specifying the commands for each direction.
---
---If the operations are |cmdline| commands, prefer
---|ImpairativeOperations:command_pair| which also handles |count|.
---@param args ImpairativeOperationsFunctionPairArgs See |ImpairativeOperationsFunctionPairArgs|
---@return ImpairativeOperations
function ImpairativeOperations:function_pair(args)
    vim.validate {
        key = {args.key, 'string'},
        desc = {args.desc, validate_desc, 'ImpairativeDesc'},
        backward = {args.backward, 'callable'},
        forward = {args.forward, 'callable'},
    }
    vim.keymap.set('n', self._opts.backward .. args.key, args.backward, {desc = process_desc(args.desc, 1)})
    vim.keymap.set('n', self._opts.forward .. args.key, args.forward, {desc = process_desc(args.desc, 2)})
    return self
end

---@class ImpairativeOperationsUnifiedFunctionArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field desc? ImpairativeDesc see |ImpairativeDesc|
---@field fun fun(direction: 'backward'|'forward') The operation
local ImpairativeOperationsUnifiedFunctionArgs

---Bind operation mappings using a function that receives the direction as a parameter.
---@param args ImpairativeOperationsUnifiedFunctionArgs See |ImpairativeOperationsUnifiedFunctionArgs|
---@return ImpairativeOperations
function ImpairativeOperations:unified_function(args)
    vim.validate {
        key = {args.key, 'string'},
        desc = {args.desc, validate_desc, 'ImpairativeDesc'},
        fun = {args.fun, 'callable'},
    }
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

---@class ImpairativeOperationsJumpInBufArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field desc? ImpairativeDesc see |ImpairativeDesc|
---@field extreme? {key: string, desc?: ImpairativeDesc} Also generate mapping to jump to first and last targets
---@field fun fun(): Iter Should return a |vim.iter| with all the jump targets in the buffer
local ImpairativeOperationsJumpInBufArgs

---Bind operation mappings for jump targets in the current buffer.
---
---The `fun` argument must return a |vim.iter| which yields tables with four
---integer fields - `start_line`, `start_col`, `end_line` and `end_col` - where
---lines are 1-based and columns are 0-based.
---
---These keymaps can also be used in |Operator-pending-mode|.
---@param args ImpairativeOperationsJumpInBufArgs See |ImpairativeOperationsJumpInBufArgs|
---@return ImpairativeOperations
function ImpairativeOperations:jump_in_buf(args)
    vim.validate {
        key = {args.key, 'string'},
        desc = {args.desc, validate_desc, 'ImpairativeDesc'},
        fun = {args.fun, 'callable'},
        extreme = {args.extreme, 'table', true},
    }
    vim.keymap.set({'n', 'x', 'o'}, self._opts.backward .. args.key, function()
        local curosr = vim.api.nvim_win_get_cursor(0)

        -- Note: prevs is zero-based because otherwise modulo math becomes too weird.
        local prevs = {i = 0}
        for pos in args.fun() do
            if curosr[1] < pos.end_line then
                break
            elseif curosr[1] == pos.end_line and curosr[2] < pos.end_col then
                break
            end
            prevs[prevs.i] = pos
            prevs.i = (prevs.i + 1) % vim.v.count1
        end
        if prevs[0] == nil then
            return
        end
        if prevs[vim.v.count1 - 1] == nil then
            vim.api.nvim_win_set_cursor(0, {prevs[0].end_line, prevs[0].end_col - 1})
        else
            vim.api.nvim_win_set_cursor(0, {prevs[prevs.i].end_line, prevs[prevs.i].end_col - 1})
        end
    end, {desc = process_desc(args.desc, 1)})
    vim.keymap.set({'n', 'x', 'o'}, self._opts.forward .. args.key, function()
        local curosr = vim.api.nvim_win_get_cursor(0)

        local pos = args.fun()
        :filter(function(pos)
            if curosr[1] < pos.start_line then
                return true
            elseif curosr[1] == pos.start_line and curosr[2] < pos.start_col then
                return true
            else
                return false
            end
        end)
        :nth(vim.v.count1)
        if pos then
            vim.api.nvim_win_set_cursor(0, {pos.start_line, pos.start_col})
        end
    end, {desc = process_desc(args.desc, 2)})

    if args.extreme then
        vim.validate {
            ['extreme.key'] = {args.extreme.key, 'string'},
            ['extreme.desc'] = {args.extreme.desc, validate_desc, 'ImpairativeDesc'},
        }
        vim.keymap.set({'n', 'x', 'o'}, self._opts.backward .. args.extreme.key, function()
            local pos = args.fun():next()
            if pos then
                vim.api.nvim_win_set_cursor(0, {pos.start_line, pos.start_col})
            end
        end, {desc = process_desc(args.extreme.desc, 1)})
        vim.keymap.set({'n', 'x', 'o'}, self._opts.forward .. args.extreme.key, function()
            local pos = args.fun():last()
            if pos then
                vim.api.nvim_win_set_cursor(0, {pos.start_line, pos.start_col})
            end
        end, {desc = process_desc(args.extreme.desc, 1)})
    end

    return self
end

---@class ImpairativeOperationsCommandPairArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field backward string The "backward" command
---@field forward string The "forward" command
local ImpairativeOperationsCommandPairArgs

---Bind operation mappings by directly specifying the |cmdline| commands for each direction.
---
---Unlike |ImpairativeOperations:function_pair|, which uses functions, this
---helper method:
---* Automatically generates descriptions based on the commands.
---* Automatically passes the |count| when the mapping is activated with one.
---@param args ImpairativeOperationsCommandPairArgs See |ImpairativeOperationsCommandPairArgs|
---@return ImpairativeOperations
function ImpairativeOperations:command_pair(args)
    vim.validate {
        key = {args.key, 'string'},
        backward = {args.backward, 'string'},
        forward = {args.forward, 'string'},
    }
    return self:unified_function {
        key = args.key,
        desc = {
            backward = ('Run the "%s" command'):format(args.backward),
            forward = ('Run the "%s" command'):format(args.forward),
        },
        fun = function(direction)
            local cmd = args[direction]
            if 0 < vim.v.count then
                cmd = vim.v.count .. cmd
            end
            local ok, result = pcall(function() vim.cmd(cmd) end)
            if not ok then
              result = tostring(result):match"E%d*:.+"
              vim.notify(result, vim.log.levels.ERROR)
            end
        end
    }
end

---Parameters for function that runs the operator in |ImpairativeOperations:range_manipulation|.
---@class ImpairativeRangeOp
---@field direction 'backward'|'forward' The direction of the operator that was invoked
---@field count integer The |v:count| the operator was invoked with
---@field count1 integer The |v:count1| the operator was invoked with
---@field range_type 'line'|'char'|'block' The range of the motion
---@field start_line integer The 1-based line where the motion's selection starts
---@field end_line integer The 1-based line where the motion's selection ends
---@field start_col integer The 1-based column where the motion's selection starts
---@field end_col integer The 1-based column where the motion's selection ends
local ImpairativeRangeOp

---@class ImpairativeOperationRangeManipulationArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field line_key? string|boolean A "motion" for running the operator on the same line
---@field desc? ImpairativeDesc see |ImpairativeDesc|
---@field fun fun(args: ImpairativeRangeOp) Performs the operation. See |ImpairativeRangeOp|
local ImpairativeOperationRangeManipulationArgs

---Bind operation mappings that operates on a range in the buffer.
---
---The range works like a regular Neovim operator - either with a motion after
---the command or by running it from visual mode. Additionally, if `line_key`
---is provided, that key can be used to run the operator on the current line.
---If `line_key = true` then the key from the `key` argument will be used.
---@param args ImpairativeOperationRangeManipulationArgs See |ImpairativeOperationRangeManipulationArgs|
function ImpairativeOperations:range_manipulation(args)
    vim.validate {
        key = {args.key, 'string'},
        line_key = {args.line_key, {'string', 'boolean'}, true},
        desc = {args.desc, validate_desc, 'ImpairativeDesc'},
        fun = {args.fun, 'callable'},
    }
    local line_key
    if args.line_key == true then
        line_key = args.key
    elseif args.line_key then
        line_key = args.line_key
    end
    for i, direction in ipairs{'backward', 'forward'} do
        local function set_operator_func()
            local count = vim.v.count
            local count1 = vim.v.count1
            require'impairative._operator_func'.operatorfunc = function(range_type)
                local region_start = vim.fn.getpos("'[")
                local region_end = vim.fn.getpos("']")

                args.fun {
                    direction = direction,
                    count = count,
                    count1 = count1,
                    range_type = range_type,
                    start_line = region_start[2],
                    start_col = region_start[3],
                    end_line = region_end[2],
                    end_col = region_end[3],
                }
            end
            vim.o.operatorfunc = "v:lua.require'impairative._operator_func'.operatorfunc"
        end
        local desc = process_desc(args.desc, i)
        vim.keymap.set({'n', 'x'}, self._opts[direction] .. args.key, function()
            set_operator_func()
            vim.api.nvim_feedkeys('g@', 'ni', false)
        end, {desc = desc})
        if line_key then
            vim.keymap.set('n', self._opts[direction] .. args.key .. line_key, function()
                set_operator_func()
                vim.api.nvim_feedkeys('Vg@', 'ni', false)
            end, {desc = desc})
        end
    end
    return self
end

---@class ImpairativeOperationsTextManipulationArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field line_key? string|boolean A "motion" for running the operator on the same line
---@field desc? ImpairativeDesc see |ImpairativeDesc|
---@field backward fun(orig: string): string The "backword" text transform (typically encode)
---@field forward fun(orig: string): string The "forward" text transform (typically decode)
local ImpairativeOperationsTextManipulationArgs

---Bind operation mappings that transform text in the buffer.
---
---Impairative uses the convention set by unimpaired where the backward
---direction is for encoding and the forward direction is for decoding. This
---convention, of course, cannot be enforced for user defined mappings - but it
---is encouraged.
---
---The text is selected like a regular Neovim operator - either with a motion
---after the command or by running it from visual mode. Additionally, if
---`line_key` is provided, that key can be used to run the operator on the
---current line. If `line_key = true` then the key from the `key` argument will
---be used.
---@param args ImpairativeOperationsTextManipulationArgs See |ImpairativeOperationsTextManipulationArgs|
---@return ImpairativeOperations
function ImpairativeOperations:text_manipulation(args)
    vim.validate {
        key = {args.key, 'string'},
        line_key = {args.line_key, {'string', 'boolean'}, true},
        desc = {args.desc, validate_desc, 'ImpairativeDesc'},
        backward = {args.backward, 'callable'},
        forward = {args.forward, 'callable'},
    }
    return self:range_manipulation {
        key = args.key,
        line_key = args.line_key,
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
