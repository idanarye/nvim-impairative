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
---@field name string?
---@field backward string
---@field forward string
local ImpairativeOperationsCommandPairArgs

---@param args ImpairativeOperationsCommandPairArgs
---@return ImpairativeOperations
function ImpairativeOperations:command_pair(args)
    return self:function_pair {
        key = args.key,
        name = args.name,
        backward = function()
            vim.cmd(args.backward)
        end,
        forward = function()
            vim.cmd(args.forward)
        end,
    }
end

return ImpairativeOperations
