---@mod impairative Impairative - Pairs of complementing keybinds
local M = {}

---@class ImpairativeSetupArgs
---@field enable? string Leader keys for turning settings on in `toggling` keymaps
---@field disable? string Leader keys for turning settings off in `toggling` keymaps
---@field toggle? string Leader keys for toggling settings in `toggling` keymaps
---@field toggling? fun(helper: ImpairativeToggling) Define mappings with the supplied |ImpairativeToggling|
---@field backward? string Leader keys for turning the operation backward in `operations` keymaps
---@field forward? string Leader keys for running the operation forward in `operations` keymaps
---@field operations? fun(helper: ImpairativeOperations) Define mappings with the supplied |ImpairativeOperations|
---@field replicate_unimpaired? boolean Create (almost) the same mappings vim-unimpaired creates
local ImpairativeSetupArgs

---Configure keymaps
---
---Completly optional - the helper objects can be created and used directly.
---@param args ImpairativeSetupArgs See |ImpairativeSetupArgs|
function M.setup(args)
    if args.toggling then
        args.toggling(M.toggling {
            enable = args.enable or '[o',
            disable = args.disable or ']o',
            toggle = args.toggle or 'yo',
        })
    end
    if args.operations then
        args.operations(M.operations {
            backward = args.backward or '[',
            forward = args.forward or ']',
        })
    end
    if args.replicate_unimpaired then
        require'impairative.replicate-unimpaired'()
    end
end

---Create an |ImpairativeToggling| helper to define mappings with
---@param opts ImpairativeTogglingOptions See |ImpairativeTogglingOptions|
---@return ImpairativeToggling
function M.toggling(opts)
    return setmetatable({
        _opts = opts,
    }, {
        __index = require'impairative.toggling',
    })
end

---Create an |ImpairativeOperations| helper to define mappings with
---@param opts ImpairativeOperationsOptions See |ImpairativeOperationsOptions|
---@return ImpairativeOperations
function M.operations(opts)
    return setmetatable({
        _opts = opts,
    }, {
        __index = require'impairative.operations',
    })
end

return M
