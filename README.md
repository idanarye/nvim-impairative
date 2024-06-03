[![CI Status](https://github.com/idanarye/nvim-impairative/workflows/CI/badge.svg)](https://github.com/idanarye/nvim-impairative/actions)

INTRODUCTION
============

Impairative is a helper plugin for creating pairs of complementing keymaps:

* Toggle options on/off.
* Jump back and forth on certain lists.
* Encode/decode text using certain formats.

Impairative is inspired by [unimpaired](https://github.com/tpope/vim-unimpaired), but unlike unimpaired - which provides a big predefined set of keymaps - Impairative provides helper functions for easily defining these keymaps.

Impairative does provide, though, [an helper function that can be used to easily replicate the keymaps unimpaired defines](#usage-as-unimpaired-replacement) (although with slight modifications) - making it usable as an unimpaired replacement.

SETUP
=====

Install Impairative with your plugin manager of choice. There is no need to call `require'impairative'.setup`, [but it can still be used as an entry point](#configuring-with-setup).

CONTROLING OPTIONS
------------------

Impairative can create keymaps for option toggling.

First, create an helper object with the keymap prefixes:

```lua
require'impairative'.toggling {
    enable = '[o',
    disable = ']o',
    toggle = 'yo',
}
```

There are two ways to use Impairative's helper objects:

* Set them to a variable and use that variable:
  ```lua
  local t = require'impairative'.toggling { ... }
  t:option { ... }
  t:option { ... }
  t:option { ... }
  t:option { ... }
  ```
* Fluent API - since each key-setting method returns the helper, these methods can be chained:
  ```lua
  require'impairative'.toggling { ... }
  :option { ... }
  :option { ... }
  :option { ... }
  :option { ... }
  ```

To create keymaps for a Vim option, use the `:option` method. For example:

```lua
require'impairative'.toggling { ... }
:option {
    key = 's',
    option = 'spell',
}
```

Assuming `toggling` was called with `[o`, `]o` and `yo` as above, this will create a `[os` keymap to enable spellcheck, `]os` to disable it, and `yos` to toggle it.

For options with non-boolean values, a `values` parameter can be used to tell Impairative what is considered "on" and what is considered "off". For example:

```lua
require'impairative'.toggling { ... }
:option {
    key = 'v',
    option = 'virtualedit',
    values = { [true] = 'all', [false] = '' }
}
```

If the option is not part of `vim.o`, but still acts as a field in a Lua table, the `:field` method can be used:

```lua
require'impairative'.toggling { ... }
:field {
    key = 's',
    -- Using a regular option for the example because with builtin Vim stuff
    -- they all are regular options:
    table = vim.o,
    field = 'spell',
    name = 'Spell Check', -- for generating the description
}
```

The `:getter_setter` method can be used for more complex cases, where the option at hand is not a simple field. For example:

```lua
require'impairative'.toggling { ... }
:getter_setter {
    key = 'i',
    name = 'inlay hints',
    get = vim.lsp.inlay_hint.is_enabled,
    set = vim.lsp.inlay_hint.enable,
}
```

Finally, for maximum manual control, the `:manual` method can be used to directly specify the operation of each keymap:
```lua
require'impairative'.toggling { ... }
:manual {
    key = "t",
    name = "Treesitter context",
    enable = "TSContextEnable",
    -- Both commands and functions are supported
    disable = function()
        vim.cmd.TSContextDisable()
    end,
    toggle = "TSContextToggle",
}
```

OPERATION PAIRS
---------------

Impairative can create keymaps that come in pairs - backward and forward. This is useful for pairs of commands that negate each other - like jumping backward/forward or encoding/decoding text.

First, create an helper object with the keymap prefixes:

```lua
require'impairative'.operations {
    backward = '[',
    forward = ']',
}
```

Just like the `toggling` helper, the `operations` helper can either be bound to a variable or used with method chaining.

### GENERAL BACKWARD/FORWARD COMMANDS

The simplest way to use the `operations` helper is the `:command_pair` method, which binds keys for two Vim commands.

```lua
require'impairative'.operations { ... }
:command_pair {
    key = 'a',
    backward = 'previous',
    forward = 'next',
}
-- Note that for the first/last variant we use a second call.
-- Impairative does not know - nor does it care - that they are related.
:command_pair {
    key = 'A',
    backward = 'first',
    forward = 'last',
}
```

For more control, the `:function_pair` method can be used. It calls a Lua function instead of running a command:

```lua
require'impairative'.operations { ... }
:function_pair {
    key = 'a',
    desc = 'jump to the {previous|next} file in the argument list',
    backward = function()
        vim.cmd {
            cmd = 'previous',
            range = {vim.v.count1},
        }
    end,
    forward = function()
        vim.cmd {
            cmd = 'next',
            range = {vim.v.count1},
        }
    end,
}
```

The `desc` parameter is used to generate the description for the keymaps. The `{previous|next}` syntax resolves to `previous` for the `backward` keymap and `next` for the `forward` keymap.

More often than not, it it is more convenient to unify the `backward` and `forward` function into a single function that slightly changes its behavior based on the direction. That can easily be done with the `:unified_function` method.

```lua
require'impairative'.operations { ... }
:unified_function {
    key = 'a',
    fun = function(direction)
        vim.cmd {
            cmd = ({
                backward = 'previous',
                forward = 'next',
            })[direction],
            range = {vim.v.count1},
        }
    end,
}
```

### JUMPING

The `operations` helper can be used to pairs of backward-forward jumping commands.

The `:jump_in_buf` method can be used to jump to a location in the current buffer. It's `fun` argument must return a Vim iterator (see `:help vim.iter`) which yields tables with four integer fields - `start_line`, `start_col`, `end_line` and `end_col` - where lines are 1-based and columns are 0-based.

```lua
require'impairative'.operations { ... }
:jump_in_buf {
    key = 'h',
    desc = 'jump to the {previous|next} markdown hyperlink',
    extreme = {
        key = 'H',
        desc = 'jump to the {first|last} markdown hyperlink',
    },
    fun = function()
        -- This is a pattern for markdown hyperlinks:
        local pattern = vim.regex[=[\[.\{-}\](.\{-})]=]
        local bufnr = vim.api.nvim_get_current_buf()

        -- Helper function provided by Impairative to create iterators over
        -- ranges of numbers. Note that this function is only good enough for
        -- an example - it does not support lines with multiple hyperlinks and
        -- it does not support hyperlinks that spawn multiple lines.
        return require'impairative.util'.iter_range(1, vim.fn.line('$'))
        :map(function(line)
            local from, to = pattern:match_line(bufnr, line - 1)
            if from then
                return {
                    start_line = line,
                    start_col = from,
                    end_line = line,
                    end_col = to,
                }
            end
            -- Utilize the fact that Iter:map is actually a filter-map which skips nil results.
        end)
    end,
}
```

`:jump_in_buf` will detect the location of the cursor in the buffer and use that to determine the location to jump to.

`:jump_in_buf` has an `extreme` option for creating keymaps that jump to the first and last positions in the iterator.

Jumping to different files will have to be done manually, using `:command_pair`/`:function_pair`/`:unified_function`.

### TEXT/RANGE MANIPULATION

Impairative can create pairs of keymaps for manipulating texts and ranges:

```lua
require'impairative'.operations { ... }
:text_manipulation {
    key = 'c',
    line_key = true,
    desc = 'convert to {lower|upper} case',
    backward = string.lower,
    forward = string.upper,
}
```

These can be used either as operators (which a motion) or in visual/select mode. `line_key` adds a "motion" (actually part of an extra keymap) for operating them on the current line - either by repeating the regular `key` (like the builtin Vim commands) or - if `line_key` is set to a string - by using that string as the "motion".

For text manipulations that encode and decode for a certain format, unimpaired has set the convention that "backward" is for encoding and "forward" is for decoding. For the sake of consistency, users of Impairative are encouraged to follow that rule.

Impairative can also create keymaps that manipulate the range directly using `:range_manipulation`:

```lua
require'impairative'.operations { ... }
:range_manipulation {
    key = 'r',
    desc = '{add|remove} error marks',
    fun = function(args)
        local bufnr = vim.api.nvim_get_current_buf()
        if args.direction == 'backward' then
            vim.api.nvim_buf_set_extmark(bufnr, ns, args.start_line - 1, args.start_col - 1, {
                end_row = args.end_line - 1,
                end_col = args.end_col,
                hl_group = 'ErrorMsg',
            })
        else
            local marks = vim.api.nvim_buf_get_extmarks(
                bufnr,
                ns,
                {args.start_line - 1, args.start_col - 1},
                {args.end_line, args.end_col},
                {overlap = true}
            )
            for _, mark in ipairs(marks) do
                vim.api.nvim_buf_del_extmark(bufnr, ns, mark[1])
            end
        end
    end,
}
```

These are a bit more complex. The function receives an arguments table that contains the following fields:

* `direction` - either `'backward'` or `'forward'`, depending on the prefix key used.
* `count` and `count1` - the counts the keymap was invoked with. Don't use `vim.v.count` and `vim.v.count1` - they will contain the count of the motion rather then the operator.
* `range_type` - `'char'`, `'line'` or `'block'`.
* `start_line`, `end_line`, `start_col` and `end_col` - the selected range. Both lines and columns are 1-based.

USAGE AS UNIMPAIRED REPLACEMENT
-------------------------------

To have Impairative register [the same keymaps unimpaired does](https://github.com/tpope/vim-unimpaired/blob/v2.1/doc/unimpaired.txt), add this to your `init.lua`:

```lua
require'impairative.replicate-unimpaired'()
```

Users are encouraged though to [copy-paste the file](lua/impairative/replicate-unimpaired.lua) and edit it to their own liking.

Impairative's version of the keymaps has several differences from unimpaired's behavior:

* unimpaired's normal mode version of `[e` and `]e` work on the current line. In Impairative, they are operators.
* unimpaired's URL encoding encode spaces a `%20`. Impairative encodes them as `+`.
* Impairative's C string decoder (`]y` / `]C`) knows how to decode 32bit Unicode codepoints (the ones that start with `\U`)
* Impairative does not implement unimpaired's paste-related keymaps, because in Neovim the `'paste'` option is obsolete.
* unimpaired's `[n` and `]n` work as a text object when used after an operator. Imerative's version of them works as one would expect - regular motions.
* Impairative, unlike unimpaired, has a `[N` and `]N` version that jumps to the first and last conflict markers.

CONFIGURING WITH SETUP
----------------------

To support lazy.vim's `opts =` configuration style, Impairative's `setup` function can be used to set up the keymaps:

```lua
--- ***********************************
--- *     I M P O R T A N T ! ! !     * 
--- *                                 *
--- * These are **NOT** the defaults! *
--- * The defaults are to do nothing. *
--- ***********************************
require'impairative'.setup {
    -- Configure toggling using an helper
    enable = '[o',
    disable = ']o',
    toggle = 'yo',
    toggling = function(h)
        h:option {
            key = 'n',
            option = 'number',
        }
        h:option {
            key = 'r',
            option = 'relativenumber',
        }
        h:option {
            key = 's',
            option = 'spell',
        }
    end,

    -- Configure operations using an helper
    backward = '[',
    forward = ']',
    operations = function(h)
        h:command_pair {
            key = 'b',
            backward = 'bprevious',
            forward = 'bnext',
        }
        h:command_pair {
            key = 'B',
            backward = 'bfirst',
            forward = 'blast',
        }
    end,

    -- Defaults to false
    replicate_unimpaired = true,
}
```

The settings are grouped into three:

1. `enable`, `disable`, `toggle`, and `toggling` - create a [toggling helper](#controling-options) and pass it to the function. If the mapping leaders are not specified, they'll default to `[o`, `]o`, and `yo`.
2. `backward`, `forward`, and `operations` - create an [operations helper](#operation-pairs) and pass it to the function. If the mapping leaders are not specified, they'll default to `[` and `]`.
3. `replicate_unimpaired` - [generate the keymaps from unimpaired](#usage-as-unimpaired-replacement).


CONTRIBUTION GUIDELINES
=======================

* If your contribution can be reasonably tested with automation tests, add tests.
* Documentation comments must be compatible with both [Sumneko Language Server](https://github.com/sumneko/lua-language-server/wiki/Annotations) and [lemmy-help](https://github.com/numToStr/lemmy-help/blob/master/emmylua.md). If you do something that changes the documentation, please run `make docs` to update the vimdoc.
* Impairative uses Google's [Release Please](https://github.com/googleapis/release-please), so write your commits according to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format.
