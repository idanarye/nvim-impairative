return function()
    local impairative = require'impairative'

    impairative.toggling {
        enable = '[o',
        disable = ']o',
        toggle = 'yo',
    }
    :field {
        key = 'b',
        table = vim.o,
        field = 'background',
        values = { [true] = 'light', [false] = 'dark' }
    }
    :field {
        key = 'c',
        table = vim.o,
        field = 'cursorline',
    }
    :getter_setter {
        key = 'd',
        get = function()
            return vim.o.diff
        end,
        set = function(value)
            if value then
                vim.cmd.diffthis()
            else
                vim.cmd.diffoff()
            end
        end,
    }
    :field {
        key = 'h',
        table = vim.o,
        field = 'hlsearch',
    }
    :field {
        key = 'i',
        table = vim.o,
        field = 'ignorecase',
    }
    :field {
        key = 'l',
        table = vim.o,
        field = 'list',
    }
    :field {
        key = 'n',
        table = vim.o,
        field = 'number',
    }
    :field {
        key = 'r',
        table = vim.o,
        field = 'relativenumber',
    }
    :field {
        key = 's',
        table = vim.o,
        field = 'spell',
    }
    :field {
        key = 't',
        table = vim.o,
        field = 'colorcolumn',
        values = { [true] = '+1', [false] = '' }
    }
    :field {
        key = 'u',
        table = vim.o,
        field = 'cursorcolumn',
    }
    :field {
        key = 'v',
        table = vim.o,
        field = 'virtualedit',
        values = { [true] = 'all', [false] = '' }
    }
    :field {
        key = 'w',
        table = vim.o,
        field = 'wrap',
    }
    :getter_setter {
        key = 'x',
        get = function()
            return vim.o.cursorline and vim.o.cursorcolumn
        end,
        set = function(value)
            vim.o.cursorline = value
            vim.o.cursorcolumn = value
        end
    }

    impairative.operations {
        -- Use capital O for now to avoid conflicts
        backward = '[',
        forward = ']',
    }
    :command_pair {
        key = 'a',
        backward = 'previous',
        forward = 'next',
    }
    :command_pair {
        key = 'A',
        backward = 'first',
        forward = 'last',
    }
    :command_pair {
        key = 'b',
        backward = 'bprevious',
        forward = 'bnext',
    }
    :command_pair {
        key = 'B',
        backward = 'bfirst',
        forward = 'blast',
    }
    :command_pair {
        key = 'l',
        backward = 'lprevious',
        forward = 'lnext',
    }
    :command_pair {
        key = 'L',
        backward = 'lfirst',
        forward = 'llast',
    }
    :command_pair {
        key = '<C-l>',
        backward = 'lpfile',
        forward = 'lnfile',
    }
    :command_pair {
        key = 'q',
        backward = 'cprevious',
        forward = 'cnext',
    }
    :command_pair {
        key = 'Q',
        backward = 'cfirst',
        forward = 'clast',
    }
    :command_pair {
        key = '<C-q>',
        backward = 'cpfile',
        forward = 'cnfile',
    }
    :command_pair {
        key = 't',
        backward = 'tprevious',
        forward = 'tnext',
    }
    :command_pair {
        key = 'T',
        backward = 'tfirst',
        forward = 'tlast',
    }
    :command_pair {
        key = '<C-t>',
        backward = 'ptprevious',
        forward = 'ptnext',
    }
end
