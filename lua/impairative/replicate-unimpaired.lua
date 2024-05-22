return function()
    local impairative = require'impairative'

    impairative.toggling {
        enable = '[o',
        disable = ']o',
        toggle = 'yo',
    }
    :option {
        key = 'b',
        option = 'background',
        values = { [true] = 'light', [false] = 'dark' }
    }
    :option {
        key = 'c',
        option = 'cursorline',
    }
    :getter_setter {
        key = 'd',
        name = 'diff mode',
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
    :option {
        key = 'h',
        option = 'hlsearch',
    }
    :option {
        key = 'i',
        option = 'ignorecase',
    }
    :option {
        key = 'l',
        option = 'list',
    }
    :option {
        key = 'n',
        option = 'number',
    }
    :option {
        key = 'r',
        option = 'relativenumber',
    }
    :option {
        key = 's',
        option = 'spell',
    }
    :option {
        key = 't',
        option = 'colorcolumn',
        values = { [true] = '+1', [false] = '' }
    }
    :option {
        key = 'u',
        option = 'cursorcolumn',
    }
    :option {
        key = 'v',
        option = 'virtualedit',
        values = { [true] = 'all', [false] = '' }
    }
    :option {
        key = 'w',
        option = 'wrap',
    }
    :getter_setter {
        key = 'x',
        name = "Vim's 'cursorline' and 'cursorcolumn' options both",
        get = function()
            return vim.o.cursorline and vim.o.cursorcolumn
        end,
        set = function(value)
            vim.o.cursorline = value
            vim.o.cursorcolumn = value
        end
    }

    impairative.operations {
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
    :unified_function {
        key = 'f',
        desc = 'jump to the {previous|next} file in the directory tree',
        fun = function(direction)
            local it = require'impairative.helpers'.walk_files_tree(vim.fn.expand('%'), direction == 'backward')
            local path
            path = it:nth(math.max(1, vim.v.count))
            if path then
                require'impairative.util'.jump_to{filename = path}
            end
        end,
    }
    :unified_function {
        key = '<Space>',
        desc = 'add blank line(s) {above|below} the current line',
        fun = function(direction)
            local line_number = vim.api.nvim_win_get_cursor(0)[1]
            if direction == 'backward' then
                line_number = line_number - 1
            end
            local lines = vim.fn['repeat']({'-'}, math.max(1, vim.v.count))
            vim.api.nvim_buf_set_lines(0, line_number, line_number, true, lines)
        end,
    }
end
