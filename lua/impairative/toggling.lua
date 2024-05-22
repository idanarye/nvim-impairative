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
---@field name? string
---@field get fun(): boolean
---@field set fun(value: boolean)
local ImpairativeTogglingGetterSetterArgs

---@param args ImpairativeTogglingGetterSetterArgs
---@return ImpairativeToggling
function ImpairativeToggling:getter_setter(args)
    local function descr(fmt)
        if args.name then
            return {
                desc = fmt:format(args.name),
            }
        end
    end

    vim.keymap.set('n', self._opts.toggle .. args.key, function()
        args.set(not args.get())
    end, descr('toggle %s'))
    vim.keymap.set('n', self._opts.enable .. args.key, function()
        args.set(true)
    end, descr('enable %s'))
    vim.keymap.set('n', self._opts.disable .. args.key, function()
        args.set(false)
    end, descr('disable %s'))
    return self
end

---@class (exact) ImpairativeTogglingFieldArgs
---@field key string
---@field name? string
---@field table table
---@field field string
---@field values? {[true]: any, [false]: any}
local ImpairativeTogglingFieldArgs

---@param args ImpairativeTogglingFieldArgs
---@return ImpairativeToggling
function ImpairativeToggling:field(args)
    local help

    local name = args.name
    if name and args.values then
        name = ('%s (on means "%s", off means "%s")'):format(name, args.values[true], args.values[false])
    end
    return self:getter_setter {
        key = args.key,
        name = name,
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

---@class (exact) ImpairativeTogglingOptionArgs
---@field key string
---@field option string
---@field values? {[true]: any, [false]: any}
local ImpairativeTogglingOptionArgs

---@param args ImpairativeTogglingOptionArgs
---@return ImpairativeToggling
function ImpairativeToggling:option(args)
    return self:field {
        key = args.key,
        table = vim.o,
        field = args.option,
        name = ("Vim's '%s' option"):format(args.option),
        values = args.values,
    }
end

return ImpairativeToggling
