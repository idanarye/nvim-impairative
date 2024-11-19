---@class ImpairativeTogglingOptions
---@field enable string Leader keys for turning settings on
---@field disable string Leader keys for turning settings off
---@field toggle string Leader keys for toggling settings
---@field show_message boolean Show message when toggling or not
local ImpairativeTogglingOptions

---@class ImpairativeToggling
---@field _opts ImpairativeTogglingOptions
local ImpairativeToggling = {}

---@class ImpairativeTogglingManualArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field name? string A name for generating mapping descriptions
---@field enable string | fun() Command or function for the enable mapping
---@field disable string | fun() Command or function for the disable mapping
---@field toggle string | fun() Command or function for the toggle mapping
---@field messages? {string: string} Show message when toggling
local ImpairativeTogglingManualArgs

---Bind toggling mappings by directly specifying the commands for each mapping.
---@param args ImpairativeTogglingManualArgs See |ImpairativeTogglingManualArgs|
function ImpairativeToggling:manual(args)
    vim.validate {
        key = {args.key, 'string'},
        name = {args.name, 'string', true},
        enable = {args.enable, {'string', 'callable'}},
        disable = {args.disable, {'string', 'callable'}},
        toggle = {args.toggle, {'string', 'callable'}},
        messages = {args.messages, 'table', true},
    }
    for _, operation in ipairs{'enable', 'disable', 'toggle'} do
        local action = args[operation]
        if action then
            if type(action) == 'string' then
                local cmd = action
                action = function() vim.cmd(cmd) end
            end
            local mapping = self._opts[operation] .. args.key
            local opts
            if args.name then
                opts = {desc = ("%s %s"):format(operation, args.name)}
            end
            local msg
            if args.messages then
                msg = args.messages[operation]
            else
                msg = opts and opts.desc
            end
            if msg then
                local fn = action
                action = function()
                    fn()
                    if self._opts.show_message then
                        vim.api.nvim_echo({{msg}}, false, {})
                    end
                end
            end
            vim.keymap.set('n', mapping, action, opts)
        end
    end

    return self
end

---@class ImpairativeTogglingGetterSetterArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field name? string A name for generating mapping descriptions
---@field get fun(): boolean Checks if the toggleable thing is on or off
---@field set fun(value: boolean) Sets the value of the toggleable thing
---@field messages? {boolean: string} Show message when toggling
local ImpairativeTogglingGetterSetterArgs

---Bind toggling mappings by directly specifying a getter and a setter.
---@param args ImpairativeTogglingGetterSetterArgs See |ImpairativeTogglingGetterSetterArgs|
---@return ImpairativeToggling
function ImpairativeToggling:getter_setter(args)
    vim.validate {
        key = {args.key, 'string'},
        name = {args.name, 'string', true},
        get = {args.get, 'callable'},
        set = {args.set, 'callable'},
        messages = {args.messages, 'table', true},
    }
    local name = args.name
    local messages = args.messages
    if not messages and name then
        messages = {[true] = 'enable ' .. name, [false] = 'disable ' .. name}
    end
    local function show_message(enable)
        local msg = messages and messages[enable]
        if msg and self._opts.show_message then
            vim.api.nvim_echo({{msg}}, false, {})
        end
    end
    return self:manual {
        key = args.key,
        name = name,
        enable = function()
            args.set(true)
            show_message(true)
        end,
        disable = function()
            args.set(false)
            show_message(false)
        end,
        toggle = function()
            local enable = not args.get()
            args.set(enable)
            show_message(enable)
        end,
        messages = {},
    }
end

---@class ImpairativeTogglingFieldArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field name? string A name for generating mapping descriptions
---@field table table The Lua table that contains the field to toggle
---@field field any The name of the field in the Lua table
---@field values? {boolean: any} Use when the field is not not using boolean (e.g. `{[true] = 'on', [false] = 'off'}`)
---@field messages? {boolean: string} Show message when toggling
local ImpairativeTogglingFieldArgs

---Bind toggling mappings for a field in a Lua table.
---
---Can also be used for things that use metatables like |lua-vim-variables|,
---but if that table is |vim.o| prefer using |ImpairativeToggling:option|
---instead.
---@param args ImpairativeTogglingFieldArgs See |ImpairativeTogglingFieldArgs|
---@return ImpairativeToggling
function ImpairativeToggling:field(args)
    vim.validate {
        key = {args.key, 'string'},
        name = {args.name, 'string', true},
        table = {args.table, 'table'},
        field = {args.field, function(f) return f ~= nil end, 'some value'},
        values = {args.values, 'table', true},
        messages = {args.messages, 'table', true},
    }
    local name = args.name
    local messages = args.messages
    if not messages and name then
        messages = {[true] = 'enable ' .. name, [false] = 'disable ' .. name}
    end
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
        messages = messages,
    }
end

---@class ImpairativeTogglingOptionArgs
---@field key string The key for the mapping (will be prefixed by one of the leaders)
---@field option string The name of the Neovim option
---@field values? {boolean: any} Use when the field is not not using boolean (e.g. `{[true] = 'on', [false] = 'off'}`)
---@field messages? {boolean: string} Show message when toggling
local ImpairativeTogglingOptionArgs

---Bind toggling mappings for a Neovim option using |vim.o|.
---@param args ImpairativeTogglingOptionArgs See |ImpairativeTogglingOptionArgs|
---@return ImpairativeToggling
function ImpairativeToggling:option(args)
    vim.validate {
        key = {args.key, 'string'},
        option = {args.option, 'string'},
        values = {args.values, 'table', true},
        messages = {args.messages, 'table', true},
    }
    local messages = args.messages
    if not messages then
        if args.values then
            local prefix = (':set %s='):format(args.option)
            messages = {[true] = prefix .. args.values[true], [false] = prefix .. args.values[false]}
        else
            messages = {[true] = ':set ' .. args.option, [false] = ':set no' .. args.option}
        end
    end
    return self:field {
        key = args.key,
        table = vim.o,
        field = args.option,
        name = ("Vim's '%s' option"):format(args.option),
        values = args.values,
        messages = messages,
    }
end

return ImpairativeToggling
