local M = {}

local function reverse_in_place(table)
    local len = #table
    for i = 1, len / 2 do
        local j = len + 1 - i
        local tmp = table[i]
        table[i] = table[j]
        table[j] = tmp
    end
end

---@param start_from string
---@param backwards? boolean
---@return Iter
function M.walk_files_tree(start_from, backwards)
    local get_neighbors
    if backwards then
        function get_neighbors(for_path)
            local basename = vim.fs.basename(for_path)
            local result = {}
            local len = 1
            for name, node_type in vim.fs.dir(vim.fs.dirname(for_path)) do
                if name == basename then
                    break
                else
                    len = len + 1
                    result[len] = {name, node_type}
                end
            end
            reverse_in_place(result)
            return result
        end
    else
        function get_neighbors(for_path)
            local basename = vim.fs.basename(for_path)
            local result
            local len
            for name, node_type in vim.fs.dir(vim.fs.dirname(for_path)) do
                if name == basename then
                    result = {}
                    len = 0
                elseif result then
                    len = len + 1
                    result[len] = {name, node_type}
                end
            end
            return result or {}
        end
    end

    local stack = {}
    for path in vim.fs.parents(start_from) do
        table.insert(stack, path)
    end
    table.remove(stack)
    reverse_in_place(stack)
    if vim.fn.isdirectory(start_from) == 0 then
        table.insert(stack, start_from)
    end

    local function expand_stack_head_if_needed()
        local head_idx = #stack
        if type(stack[head_idx]) == 'table' then
            return
        end
        local dirname = vim.fs.dirname(stack[head_idx])
        local new_head = get_neighbors(stack[head_idx])
        new_head.dirname = dirname
        new_head.cursor = 0
        stack[head_idx] = new_head
    end

    return vim.iter(function()
        while next(stack) ~= nil do
            expand_stack_head_if_needed()
            local head = stack[#stack]
            head.cursor = head.cursor + 1
            local entry = head[head.cursor]
            if not entry then
                table.remove(stack)
            elseif entry[2] == 'directory' then
                table.insert(stack, vim.fs.joinpath(head.dirname, entry[1]))
            else
                return vim.fs.joinpath(head.dirname, entry[1])
            end
        end
    end)
end

function M.encode_url(text)
    -- Ported from unimpaired: iconv trick to convert utf-8 bytes to 8bits indiviual char:
    text = vim.iconv(text, 'latin1', 'utf-8')
    return text:gsub([=[[^A-Za-z0-9_.~-]]=], function(m)
        if m == ' ' then
            return '+'
        else
            return ('%%%02X'):format(m:byte())
        end
    end)
end

function M.decode_url(text)
    -- Ported from unimpaired
    text = text:gsub('+', ' ')
    text = text:gsub([=[%%(%x%x)]=], function(m)
        return string.char(tonumber(m, 16))
    end)
    return vim.iconv(text, 'utf-8', 'latin1')
end

local function lazy_cache(fun)
    local cached
    return function()
        if cached == nil then
            cached = fun()
        end
        return cached
    end
end

local XML_ENCODE_MAPPING = lazy_cache(function()
    return {
        ['<'] = '&lt;',
        ['>'] = '&gt;',
        ['&']  = '&amp;',
        ['\''] = '&apos;',
        ['"'] = '&quot;',
    }
end)

function M.encode_xml(text)
    return text:gsub([=[[<>&'"]]=], function(m)
        return XML_ENCODE_MAPPING()[m]
    end)
end

local XML_DECODE_MAPPING = lazy_cache(function()
    return {
        Chi = '\206\167',         Psi = '\206\168',        Ccedil = '\195\135',     Beta = '\206\146',
        macr = '\194\175',        Pi = '\206\160',         Atilde = '\195\131',     Aring = '\195\133',
        Alpha = '\206\145',       Ouml = '\195\150',       Agrave = '\195\128',     Acirc = '\195\130',
        Aacute = '\195\129',      AElig = '\195\134',      lowast = '\226\136\151', Ograve = '\195\146',
        Ocirc = '\195\148',       Oacute = '\195\147',     OElig = '\197\146',      ldquo = '\226\128\156',
        Nu = '\206\157',          lceil = '\226\140\136',  Ntilde = '\195\145',     larr = '\226\134\144',
        oplus = '\226\138\149',   image = '\226\132\145',  ordf = '\194\170',       lArr = '\226\135\144',
        mu = '\206\188',          kappa = '\206\186',      oslash = '\195\184',     iuml = '\195\175',
        isin = '\226\136\136',    otilde = '\195\181',     iquest = '\194\191',     iota = '\206\185',
        otimes = '\226\138\151',  infin = '\226\136\158',  para = '\194\182',       igrave = '\195\172',
        iexcl = '\194\161',       icirc = '\195\174',      iacute = '\195\173',     hellip = '\226\128\166',
        permil = '\226\128\176',  hearts = '\226\153\165', micro = '\194\181',      harr = '\226\134\148',
        sim = '\226\136\188',     hArr = '\226\135\148',   dagger = '\226\128\160', piv = '\207\150',
        pound = '\194\163',       prop = '\226\136\157',   prod = '\226\136\143',   prime = '\226\128\178',
        psi = '\207\136',         rArr = '\226\135\146',   radic = '\226\136\154',  rang = '\226\140\170',
        raquo = '\194\187',       rarr = '\226\134\146',   lambda = '\206\187',     rdquo = '\226\128\157',
        alpha = '\206\177',       rfloor = '\226\140\139', rho = '\207\129',        rlm = '\226\128\143',
        sbquo = '\226\128\154',   scaron = '\197\161',     frasl = '\226\129\132',  sect = '\194\167',
        shy = '\194\173',         sigma = '\207\131',      mdash = '\226\128\148',  sube = '\226\138\134',
        sum = '\226\136\145',     sup = '\226\138\131',    sup2 = '\194\178',       szlig = '\195\159',
        tau = '\207\132',         there4 = '\226\136\180', theta = '\206\184',      tilde = '\203\156',
        quot = '"',               amp = '&',               apos = '\'',             trade = '\226\132\162',
        uArr = '\226\135\145',    times = '\195\151',      uarr = '\226\134\145',   uml = '\194\168',
        upsih = '\207\146',       gamma = '\206\179',      upsilon = '\207\133',    uuml = '\195\188',
        frac34 = '\194\190',      frac14 = '\194\188',     frac12 = '\194\189',     forall = '\226\136\128',
        zwj = '\226\128\141',     fnof = '\198\146',       zeta = '\206\182',       yuml = '\195\191',
        euro = '\226\130\172',    yen = '\194\165',        euml = '\195\171',       eth = '\195\176',
        eta = '\206\183',         weierp = '\226\132\152', equiv = '\226\137\161',  epsilon = '\206\181',
        yacute = '\195\189',      ensp = '\226\128\130',   xi = '\206\190',         emsp = '\226\128\131',
        ugrave = '\195\185',      ucirc = '\195\187',      egrave = '\195\168',     ecirc = '\195\170',
        eacute = '\195\169',      divide = '\195\183',     diams = '\226\153\166',  reg = '\194\174',
        darr = '\226\134\147',    empty = '\226\136\133',  thinsp = '\226\128\137', dArr = '\226\135\147',
        thetasym = '\207\145',    curren = '\194\164',     cup = '\226\136\170',    zwnj = '\226\128\140',
        crarr = '\226\134\181',   cong = '\226\137\133',   clubs = '\226\153\163',  supe = '\226\138\135',
        sup3 = '\194\179',        delta = '\206\180',      sup1 = '\194\185',       cent = '\194\162',
        cedil = '\194\184',       ccedil = '\195\167',     cap = '\226\136\169',    bull = '\226\128\162',
        spades = '\226\153\160',  brvbar = '\194\166',     exist = '\226\136\131',  sigmaf = '\207\130',
        bdquo = '\226\128\158',   auml = '\195\164',       atilde = '\195\163',     uacute = '\195\186',
        thorn = '\195\190',       sub = '\226\138\130',    Omicron = '\206\159',    Oslash = '\195\152',
        ['and'] = '\226\136\167', real = '\226\132\156',   ge = '\226\137\165',     le = '\226\137\164',
        rceil = '\226\140\137',   lt = '<',                gt = '>',                plusmn = '\194\177',
        ne = '\226\137\160',      pi = '\207\128',         phi = '\207\134',        perp = '\226\138\165',
        lang = '\226\140\169',    ouml = '\195\182',       ordm = '\194\186',       ['or'] = '\226\136\168',
        omicron = '\206\191',     omega = '\207\137',      oline = '\226\128\190',  ograve = '\195\178',
        oelig = '\197\147',       ocirc = '\195\180',      oacute = '\195\179',     nu = '\206\189',
        ntilde = '\195\177',      nsub = '\226\138\132',   notin = '\226\136\137',  ['not'] = '\194\172',
        ni = '\226\136\139',      ndash = '\226\128\147',  nbsp = '\194\160',       nabla = '\226\136\135',
        minus = '\226\136\146',   middot = '\194\183',     lsquo = '\226\128\152',  copy = '\194\169',
        lrm = '\226\128\142',     loz = '\226\151\138',    lfloor = '\226\140\138', laquo = '\194\171',
        part = '\226\136\130',    int = '\226\136\171',    Rho = '\206\161',        Phi = '\206\166',
        Scaron = '\197\160',      beta = '\206\178',       Sigma = '\206\163',      THORN = '\195\158',
        chi = '\207\135',         Tau = '\206\164',        Omega = '\206\169',      Uacute = '\195\154',
        Ucirc = '\195\155',       Igrave = '\195\140',     Upsilon = '\206\165',    Uuml = '\195\156',
        Prime = '\226\128\179',   Xi = '\206\158',         Otilde = '\195\149',     Yuml = '\197\184',
        Zeta = '\206\150',        aacute = '\195\161',     acirc = '\195\162',      acute = '\194\180',
        Auml = '\195\132',        asymp = '\226\137\136',  sdot = '\226\139\133',   aring = '\195\165',
        ang = '\226\136\160',     circ = '\203\134',       rsquo = '\226\128\153',  alefsym = '\226\132\181',
        rsaquo = '\226\128\186',  agrave = '\195\160',     aelig = '\195\166',      Mu = '\206\156',
        Lambda = '\206\155',      Kappa = '\206\154',      Iuml = '\195\143',       Iota = '\206\153',
        Yacute = '\195\157',      deg = '\194\176',        Icirc = '\195\142',      Iacute = '\195\141',
        Gamma = '\206\147',       Ugrave = '\195\153',     Euml = '\195\139',       Eta = '\206\151',
        Theta = '\206\152',       Epsilon = '\206\149',    Egrave = '\195\136',     Ecirc = '\195\138',
        Eacute = '\195\137',      ETH = '\195\144',        Delta = '\206\148',      lsaquo = '\226\128\185',
        Dagger = '\226\128\161',
    }
end)

function M.decode_xml(text)
    return text:gsub([=[&(%a-);]=], function(m)
        return XML_DECODE_MAPPING()[m]
    end)
end

local STRING_ENCODE_MAPPING = lazy_cache(function()
    return {
        [' '] = ' ',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['"'] = '\\"',
        ['\\'] = '\\\\',
    }
end)

function M.encode_string(text)
    return text:gsub([=[[%G"\]]=], function(m)
        return STRING_ENCODE_MAPPING()[m] or ('\\%03o'):format(m:byte())
    end)
end

function M.decode_string(text)
    local it = vim.gsplit(text, [=[\]=])
    local parts = table.pack(it())

    local function add(part)
        if part then
            parts.n = parts.n + 1
            parts[parts.n] = part
        end
    end

    local mapping = {
        ['a'] = '\a',
        ['b'] = '\b',
        ['f'] = '\f',
        ['n'] = '\n',
        ['r'] = '\r',
        ['t'] = '\t',
        ['v'] = '\v',
        ['"'] = '"',
        ['\''] = '\'',
        ['?'] = '?',
        [''] = function()
            add('\\')
            add(it())
        end,
        ['u'] = function(part)
            local hex = part:sub(1, 4)
            if #hex == 4 then
                local codepoint = tonumber(hex, 16)
                if codepoint then
                    add(vim.fn.nr2char(codepoint))
                    add(part:sub(5))
                    return
                end
            end
            add('\\u')
            add(part)
        end,
        ['U'] = function(part)
            local hex = part:sub(1, 8)
            if #hex == 8 then
                local codepoint = tonumber(hex, 16)
                if codepoint then
                    add(vim.fn.nr2char(codepoint))
                    add(part:sub(9))
                    return
                end
            end
            add('\\u')
            add(part)
        end,
    }

    for part in it do
        local indicator = part:sub(1, 1)
        local mapped_to = mapping[indicator]
        if type(mapped_to) == 'string' then
            add(mapped_to)
            add(part:sub(2))
        elseif mapped_to then -- is a function
            mapped_to(part:sub(2))
        else
            local octal = part:match([=[^[0-7]*]=]):sub(1, 3)
            local octal_len = #octal
            if 0 < octal_len then
                add(string.char(tonumber(octal, 8)))
                add(part:sub(octal_len + 1))
            else
                -- Will add the "escape" sequence as is
                add('\\')
                add(part)
            end
        end
    end
    return table.concat(parts)
end

---@return Iter
function M.conflict_marker_locations()
    local pattern = vim.regex[=[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]=]
    local entire_line_pattern = vim.regex[=[^.*$]=]
    local bufnr = vim.api.nvim_get_current_buf()
    return require'impairative.util'.iter_range(1, vim.fn.line('$'))
    :filter(function(line)
        return pattern:match_line(bufnr, line - 1) ~= nil
    end)
    :map(function(line)
        local start_col, end_col = entire_line_pattern:match_line(bufnr, line - 1)
        return {
            start_line = line,
            start_col = start_col,
            end_line = line,
            end_col = end_col,
        }
    end)
end

return M
