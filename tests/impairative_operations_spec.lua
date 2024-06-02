describe('Impairative operations', function()
    it('command pair', function()
        -- Do it in a new window to avoid trouble
        vim.cmd.new()

        require'impairative'.operations {
            backward = '[',
            forward = ']',
        }
        :command_pair {
            key = '1',
            backward = 'first',
            forward = 'last',
        }

        vim.cmd.args('foo', 'bar', 'baz')
        vim.cmd.argument(2)

        assert.equal(vim.fn.bufname(), 'bar')

        vim.api.nvim_feedkeys('[1', 'mix', false)
        assert.equal(vim.fn.bufname(), 'foo')

        vim.api.nvim_feedkeys(']1', 'mix', false)
        assert.equal(vim.fn.bufname(), 'baz')

        vim.cmd'close!'
    end)

    it('function pair', function()
        local data = {}

        require'impairative'.operations {
            backward = '[',
            forward = ']',
        }
        :function_pair {
            key = '2',
            backward = function()
                table.insert(data, 'b')
            end,
            forward = function()
                table.insert(data, 'f')
            end,
        }

        vim.api.nvim_feedkeys('[2', 'mix', false)
        assert.are.same(data, {'b'})

        vim.api.nvim_feedkeys(']2', 'mix', false)
        assert.are.same(data, {'b', 'f'})
    end)

    it('unified function', function()
        local data = {}

        require'impairative'.operations {
            backward = '[',
            forward = ']',
        }
        :unified_function {
            key = '3',
            fun = function(direction)
                table.insert(data, direction)
            end,
        }

        vim.api.nvim_feedkeys('[3', 'mix', false)
        assert.are.same(data, {'backward'})

        vim.api.nvim_feedkeys(']3', 'mix', false)
        assert.are.same(data, {'backward', 'forward'})
    end)

    it('jump_in_buf', function()
        -- Do it in a new window to avoid trouble
        vim.cmd.new()

        require'impairative'.operations {
            backward = '[',
            forward = ']',
        }
        :jump_in_buf {
            key = '4',
            extreme = {key = '5'},
            fun = function()
                return vim.iter {
                    {start_line = 2, start_col = 0, end_line = 2, end_col = 1},
                    {start_line = 4, start_col = 0, end_line = 4, end_col = 1},
                    {start_line = 6, start_col = 0, end_line = 6, end_col = 1},
                    {start_line = 8, start_col = 0, end_line = 8, end_col = 1},
                }
            end,
        }

        vim.api.nvim_buf_set_lines(0, 0, 0, true, vim.fn['repeat']({''}, 10))

        vim.api.nvim_feedkeys('[5', 'mix', false)
        assert.equal(vim.api.nvim_win_get_cursor(0)[1], 2)
        vim.api.nvim_feedkeys(']4', 'mix', false)
        assert.equal(vim.api.nvim_win_get_cursor(0)[1], 4)

        vim.api.nvim_feedkeys(']5', 'mix', false)
        assert.equal(vim.api.nvim_win_get_cursor(0)[1], 8)
        vim.api.nvim_feedkeys('[4', 'mix', false)
        assert.equal(vim.api.nvim_win_get_cursor(0)[1], 6)

        vim.cmd'close!'
    end)

    it('text_manipulation', function()
        -- Do it in a new window to avoid trouble
        vim.cmd.new()

        require'impairative'.operations {
            backward = '[',
            forward = ']',
        }
        :text_manipulation {
            key = '5',
            backward = string.lower,
            forward = string.upper,
        }

        vim.api.nvim_buf_set_lines(0, 0, 0, true, {'Hello World'})

        vim.api.nvim_win_set_cursor(0, {1, 0})
        vim.api.nvim_feedkeys('[5iw', 'mix', false)
        assert.equal(vim.api.nvim_buf_get_lines(0, 0, 1, true)[1] , 'hello World')

        vim.api.nvim_win_set_cursor(0, {1, 6})
        vim.api.nvim_feedkeys(']5iw', 'mix', false)
        assert.equal(vim.api.nvim_buf_get_lines(0, 0, 1, true)[1] , 'hello WORLD')

        vim.cmd'close!'
    end)

    it('range_manipulation', function()
        vim.cmd.new()

        local data = {}

        require'impairative'.operations {
            backward = '[',
            forward = ']',
        }
        :range_manipulation {
            key = '6',
            fun = function(args)
                table.insert(data, {
                    args.direction,
                    vim.api.nvim_buf_get_text(0, args.start_line - 1, args.start_col - 1, args.end_line - 1, args.end_col, {})[1]
                })
            end,
        }

        vim.api.nvim_buf_set_lines(0, 0, 0, true, {'hello world'})

        vim.api.nvim_win_set_cursor(0, {1, 0})
        vim.api.nvim_feedkeys('[6iw', 'mix', false)

        vim.api.nvim_win_set_cursor(0, {1, 6})
        vim.api.nvim_feedkeys(']6iw', 'mix', false)

        assert.are.same(data, {
            {'backward', 'hello'},
            {'forward', 'world'},
        })

        vim.cmd'close!'
    end)
end)
