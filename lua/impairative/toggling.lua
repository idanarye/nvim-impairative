---@class ImpairativeTogglingOptions
---@field enable string Leader keys for turning settings on
---@field disable string Leader keys for turning settings off
---@field toggle string Leader keys for toggling settings
local ImpairativeTogglingOptions

---@class ImpairativeToggling
---@field _opts ImpairativeTogglingOptions
local ImpairativeToggling = {}

---@class ImpairativeTogglingGetterSetterArgs
---@field key string
---@field name string?
---@field get fun(): boolean
---@field set fun(value: boolean)
local ImpairativeTogglingGetterSetterArgs

---@param args ImpairativeTogglingGetterSetterArgs
---@return ImpairativeToggling
function ImpairativeToggling:getter_setter(args)
    vim.keymap.set('n', self._opts.toggle .. args.key, function()
        args.set(not args.get())
    end)
    vim.keymap.set('n', self._opts.enable .. args.key, function()
        args.set(true)
    end)
    vim.keymap.set('n', self._opts.disable .. args.key, function()
        args.set(false)
    end)
    return self
end

--local ImpairativeTogglingFieldArgsValues

---@class (exact) ImpairativeTogglingFieldArgs
---@field key string
---@field name string?
---@field table table
---@field field string
---@field values? {[true]: any, [false]: any}
local ImpairativeTogglingFieldArgs

---@param args ImpairativeTogglingFieldArgs
---@return ImpairativeToggling
function ImpairativeToggling:field(args)
    return self:getter_setter {
        key = args.key,
        name = args.name,
        get = function()
            if args.values then
                return args.table[args.field] == args.values[true]
            else
                return args.table[args.field]
            end
        end,
        set = function(value)
            if args.values then
                args.table[args.field] = args.values[value]
            else
                args.table[args.field] = value
            end
        end,
    }
end

return ImpairativeToggling
