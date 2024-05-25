[![CI Status](https://github.com/idanarye/nvim-impairative/workflows/CI/badge.svg)](https://github.com/idanarye/nvim-impairative/actions)

INTRODUCTION
============

SETUP
=====

Install Impairative with your plugin manager of choice. There is no need to call `require'impairative'.setup`.

CONTROLING OPTIONS
------------------

Impairative can create keymaps for option toggling. First, create an helper object with the keymap prefixes:

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

Finally, the `:getter_setter` method can be used for more complex cases, where the option at hand is not a simple field. For example:

```lua
require'impairative'.toggling { ... }
:getter_setter {
    key = 'i',
    name = 'inlay hints',
    get = vim.lsp.inlay_hint.is_enabled,
    set = vim.lsp.inlay_hint.enable,
}
```

USAGE AS UNIMPAIRED REPLACEMENT
-------------------------------

To have Impairative register the same keymaps unimpaired does, add this to your `init.lua`:

```lua
require'impairative.replicate-unimpaired'()
```

Users are required though to [copy-paste the file](lua/impairative/replicate-unimpaired.lua) and edit it to their own liking.

Impairative's version of the keymaps has several differences from unimpaired's behavior:

* unimpaired's normal mode version of `[e` and `]e` work on the current line. In Impairative, they are operators.
* unimpaired's URL encoding encode spaces a `%20`. Impairative encodes them as `+`.
* Impairative's C string decoder (`]y` / `]C`) knows how to decode 32bit Unicode codepoints (the ones that start with `\U`)
* Impairative does not implement unimpaired's paste-related keymaps, because in Neovim the `'paste'` option is obsolete.
* unimpaired's `[n` and `]n` work as a text object when used after an operator. Imerative's version of them work as one would expect - regular motions.

CONTRIBUTION GUIDELINES
=======================

* If your contribution can be reasonably tested with automation tests, add tests.
* Documentation comments must be compatible with both [Sumneko Language Server](https://github.com/sumneko/lua-language-server/wiki/Annotations) and [lemmy-help](https://github.com/numToStr/lemmy-help/blob/master/emmylua.md). If you do something that changes the documentation, please run `make docs` to update the vimdoc.
* Impairative uses Google's [Release Please](https://github.com/googleapis/release-please), so write your commits according to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format.
