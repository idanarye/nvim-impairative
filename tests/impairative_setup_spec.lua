describe('Impairative setup', function()
    it('default leaders', function()
        local data = {
            field = false,
            operations = {},
        }

        require'impairative'.setup {
            toggling = function(h)
                h:field {
                    key = '!',
                    table = data,
                    field = 'field',
                }
            end,
            operations = function(h)
                h:unified_function {
                    key = '!',
                    fun = function(direction)
                        table.insert(data.operations, direction)
                    end,
                }
            end,
        }

        vim.api.nvim_feedkeys('[o!', 'mix', false)
        assert.equal(data.field, true)
        vim.api.nvim_feedkeys('[o!', 'mix', false)
        assert.equal(data.field, true)

        vim.api.nvim_feedkeys(']o!', 'mix', false)
        assert.equal(data.field, false)
        vim.api.nvim_feedkeys(']o!', 'mix', false)
        assert.equal(data.field, false)

        vim.api.nvim_feedkeys('yo!', 'mix', false)
        assert.equal(data.field, true)
        vim.api.nvim_feedkeys('yo!', 'mix', false)
        assert.equal(data.field, false)

        vim.api.nvim_feedkeys('[!', 'mix', false)
        assert.are.same(data.operations, {'backward'})

        vim.api.nvim_feedkeys(']!', 'mix', false)
        assert.are.same(data.operations, {'backward', 'forward'})
    end)

    it('custom leaders', function()
        local data = {
            field = false,
            operations = {},
        }

        require'impairative'.setup {
            enable = '<M-[>o',
            disable = '<M-]>o',
            toggle = '<M-y>o',
            toggling = function(h)
                h:field {
                    key = '@',
                    table = data,
                    field = 'field',
                }
            end,
            backward = '<M-[>',
            forward = '<M-]>',
            operations = function(h)
                h:unified_function {
                    key = '@',
                    fun = function(direction)
                        table.insert(data.operations, direction)
                    end,
                }
            end,
        }

        local function feedkeys(keys)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'mix', true)
        end

        feedkeys('<M-[>o@')
        assert.equal(data.field, true)
        feedkeys('<M-[>o@')
         assert.equal(data.field, true)

        feedkeys('<M-]>o@')
        assert.equal(data.field, false)
        feedkeys('<M-]>o@')
        assert.equal(data.field, false)

        feedkeys('<M-y>o@')
        assert.equal(data.field, true)
        feedkeys('<M-y>o@')
        assert.equal(data.field, false)

        feedkeys('<M-[>@')
        assert.are.same(data.operations, {'backward'})

        feedkeys('<M-]>@')
        assert.are.same(data.operations, {'backward', 'forward'})
    end)
end)
