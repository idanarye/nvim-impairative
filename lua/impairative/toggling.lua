---@class ImpairativeTogglingOptions
---@field enable string Leader keys for turning settings on
---@field disable string Leader keys for turning settings off
---@field toggle string Leader keys for toggling settings
local ImpairativeTogglingOptions

---@class ImpairativeToggling
---@field _opts ImpairativeTogglingOptions
local ImpairativeToggling = {}

---@class ImpairativeTogglingManualArgs
---@field key string
---@field name? string
---@field enable string | fun()
---@field disable string | fun()
---@field toggle string | fun()
local ImpairativeTogglingManualArgs

---@param args ImpairativeTogglingManualArgs
function ImpairativeToggling:manual(args)
    for _, operation in ipairs{'enable', 'disable', 'toggle'} do
        local action = args[operation]
        if action then
            if type(action) == 'string' then
                action = ('<Cmd>%s<Cr>'):format(action)
            end
            local mapping = self._opts[operation] .. args.key
            local opts
            if args.name then
                opts = {desc = ("%s %s"):format(operation, args.name)}
            end
            vim.keymap.set('n', mapping, action, opts)
        end
    end

    return self
end

---@class ImpairativeTogglingGetterSetterArgs
---@field key string
---@field name? string
---@field get fun(): boolean
---@field set fun(value: boolean)
local ImpairativeTogglingGetterSetterArgs

---@param args ImpairativeTogglingGetterSetterArgs
---@return ImpairativeToggling
function ImpairativeToggling:getter_setter(args)
    return self:manual {
        key = args.key,
        name = args.name,
        enable = function()
            args.set(true)
        end,
        disable = function()
            args.set(false)
        end,
        toggle = function()
            args.set(not args.get())
        end,
    }
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
