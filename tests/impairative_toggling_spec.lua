describe('Impairative toggling', function()
    it('options', function()
        -- Do it in a new window to avoid trouble
        vim.cmd.new()

        require'impairative'.toggling {
            enable = '[o',
            disable = ']o',
            toggle = 'yo',
        }
        :option {
            key = '1',
            option = 'spell',
        }
        vim.o.spell = false
        assert.equal(vim.o.spell, false)

        vim.api.nvim_feedkeys('[o1', 'mix', false)
        assert.equal(vim.o.spell, true)
        vim.api.nvim_feedkeys('[o1', 'mix', false)
        assert.equal(vim.o.spell, true)

        vim.api.nvim_feedkeys(']o1', 'mix', false)
        assert.equal(vim.o.spell, false)
        vim.api.nvim_feedkeys(']o1', 'mix', false)
        assert.equal(vim.o.spell, false)

        vim.api.nvim_feedkeys('yo1', 'mix', false)
        assert.equal(vim.o.spell, true)
        vim.api.nvim_feedkeys('yo1', 'mix', false)
        assert.equal(vim.o.spell, false)

        vim.cmd.close()
    end)

    it('field', function()
        local data = {field = false}

        require'impairative'.toggling {
            enable = '[o',
            disable = ']o',
            toggle = 'yo',
        }
        :field {
            key = '2',
            table = data,
            field = 'field',
        }

        vim.api.nvim_feedkeys('[o2', 'mix', false)
        assert.equal(data.field, true)
        vim.api.nvim_feedkeys('[o2', 'mix', false)
        assert.equal(data.field, true)

        vim.api.nvim_feedkeys(']o2', 'mix', false)
        assert.equal(data.field, false)
        vim.api.nvim_feedkeys(']o2', 'mix', false)
        assert.equal(data.field, false)

        vim.api.nvim_feedkeys('yo2', 'mix', false)
        assert.equal(data.field, true)
        vim.api.nvim_feedkeys('yo2', 'mix', false)
        assert.equal(data.field, false)
    end)

    it('field with values table', function()
        local data = {field = 'f'}

        require'impairative'.toggling {
            enable = '[o',
            disable = ']o',
            toggle = 'yo',
        }
        :field {
            key = '3',
            table = data,
            field = 'field',
            values = {[false] = 'f', [true] = 't'}
        }

        vim.api.nvim_feedkeys('[o3', 'mix', false)
        assert.equal(data.field, 't')
        vim.api.nvim_feedkeys('[o3', 'mix', false)
        assert.equal(data.field, 't')

        vim.api.nvim_feedkeys(']o3', 'mix', false)
        assert.equal(data.field, 'f')
        vim.api.nvim_feedkeys(']o3', 'mix', false)
        assert.equal(data.field, 'f')

        vim.api.nvim_feedkeys('yo3', 'mix', false)
        assert.equal(data.field, 't')
        vim.api.nvim_feedkeys('yo3', 'mix', false)
        assert.equal(data.field, 'f')
    end)

    it('getter / setter', function()
        local data = false

        require'impairative'.toggling {
            enable = '[o',
            disable = ']o',
            toggle = 'yo',
        }
        :getter_setter {
            key = '4',
            get = function()
                return data
            end,
            set = function(value)
                data = value
            end
        }

        vim.api.nvim_feedkeys('[o4', 'mix', false)
        assert.equal(data, true)
        vim.api.nvim_feedkeys('[o4', 'mix', false)
        assert.equal(data, true)

        vim.api.nvim_feedkeys(']o4', 'mix', false)
        assert.equal(data, false)
        vim.api.nvim_feedkeys(']o4', 'mix', false)
        assert.equal(data, false)

        vim.api.nvim_feedkeys('yo4', 'mix', false)
        assert.equal(data, true)
        vim.api.nvim_feedkeys('yo4', 'mix', false)
        assert.equal(data, false)
    end)
end)

