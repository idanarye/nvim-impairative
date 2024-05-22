---@class ImpairativeOperationsOptions
---@field backward string Leader keys for turning the operation backward
---@field forward string Leader keys for running the operation forward
local ImpairativeOperationsOptions

---@class ImpairativeOperations
---@field _opts ImpairativeOperationsOptions
local ImpairativeOperations = {}

---@class ImpairativeOperationsFunctionPairArgs
---@field key string
---@field name string?
---@field backward fun()
---@field forward fun()
local ImpairativeOperationsFunctionPairArgs

---@param args ImpairativeOperationsFunctionPairArgs
---@return ImpairativeOperations
function ImpairativeOperations:function_pair(args)
    vim.keymap.set('n', self._opts.backward .. args.key, args.backward)
    vim.keymap.set('n', self._opts.forward .. args.key, args.forward)
    return self
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

local function keybind_text_manipulation_function(keys, func)
    vim.keymap.set({'n', 'x'}, keys, function()
        require'impairative._operator_func'.change_text = func
        vim.o.operatorfunc = "v:lua.require'impairative._operator_func'.operatorfunc"
        vim.api.nvim_feedkeys('g@', 'ni', false)
    end)
end

---@class ImpairativeOperationsTextManipulationArgs
---@field key string
---@field name string?
---@field backward fun(orig: string): string
---@field forward fun(orig: string): string
local ImpairativeOperationsTextManipulationArgs

---@param args ImpairativeOperationsTextManipulationArgs
---@return ImpairativeOperations
function ImpairativeOperations:text_manipulation(args)
    keybind_text_manipulation_function(self._opts.backward .. args.key, args.backward)
    keybind_text_manipulation_function(self._opts.forward .. args.key, args.forward)
    return self
end

return ImpairativeOperations
