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
        AElig = 198,    Aacute = 193,  Acirc = 194,    Agrave = 192,
        Alpha = 913,    Aring = 197,   Atilde = 195,   Auml = 196,
        Beta = 914,     Ccedil = 199,  Chi = 935,      Dagger = 8225,
        Delta = 916,    ETH = 208,     Eacute = 201,   Ecirc = 202,
        Egrave = 200,   Epsilon = 917, Eta = 919,      Euml = 203,
        Gamma = 915,    Iacute = 205,  Icirc = 206,    Igrave = 204,
        Iota = 921,     Iuml = 207,    Kappa = 922,    Lambda = 923,
        Mu = 924,       Ntilde = 209,  Nu = 925,       OElig = 338,
        Oacute = 211,   Ocirc = 212,   Ograve = 210,   Omega = 937,
        Omicron = 927,  Oslash = 216,  Otilde = 213,   Ouml = 214,
        Phi = 934,      Pi = 928,      Prime = 8243,   Psi = 936,
        Rho = 929,      Scaron = 352,  Sigma = 931,    THORN = 222,
        Tau = 932,      Theta = 920,   Uacute = 218,   Ucirc = 219,
        Ugrave = 217,   Upsilon = 933, Uuml = 220,     Xi = 926,
        Yacute = 221,   Yuml = 376,    Zeta = 918,     aacute = 225,
        acirc = 226,    acute = 180,   aelig = 230,    agrave = 224,
        alefsym = 8501, alpha = 945,   amp = 38,       ["and"] = 8743,
        ang = 8736,     apos = 39,     aring = 229,    asymp = 8776,
        atilde = 227,   auml = 228,    bdquo = 8222,   beta = 946,
        brvbar = 166,   bull = 8226,   cap = 8745,     ccedil = 231,
        cedil = 184,    cent = 162,    chi = 967,      circ = 710,
        clubs = 9827,   cong = 8773,   copy = 169,     crarr = 8629,
        cup = 8746,     curren = 164,  dArr = 8659,    dagger = 8224,
        darr = 8595,    deg = 176,     delta = 948,    diams = 9830,
        divide = 247,   eacute = 233,  ecirc = 234,    egrave = 232,
        empty = 8709,   emsp = 8195,   ensp = 8194,    epsilon = 949,
        equiv = 8801,   eta = 951,     eth = 240,      euml = 235,
        euro = 8364,    exist = 8707,  fnof = 402,     forall = 8704,
        frac12 = 189,   frac14 = 188,  frac34 = 190,   frasl = 8260,
        gamma = 947,    ge = 8805,     gt = 62,        hArr = 8660,
        harr = 8596,    hearts = 9829, hellip = 8230,  iacute = 237,
        icirc = 238,    iexcl = 161,   igrave = 236,   image = 8465,
        infin = 8734,   int = 8747,    iota = 953,     iquest = 191,
        isin = 8712,    iuml = 239,    kappa = 954,    lArr = 8656,
        lambda = 955,   lang = 9001,   laquo = 171,    larr = 8592,
        lceil = 8968,   ldquo = 8220,  le = 8804,      lfloor = 8970,
        lowast = 8727,  loz = 9674,    lrm = 8206,     lsaquo = 8249,
        lsquo = 8216,   lt = 60,       macr = 175,     mdash = 8212,
        micro = 181,    middot = 183,  minus = 8722,   mu = 956,
        nabla = 8711,   nbsp = 160,    ndash = 8211,   ne = 8800,
        ni = 8715,      ["not"] = 172, notin = 8713,   nsub = 8836,
        ntilde = 241,   nu = 957,      oacute = 243,   ocirc = 244,
        oelig = 339,    ograve = 242,  oline = 8254,   omega = 969,
        omicron = 959,  oplus = 8853,  ["or"] = 8744,  ordf = 170,
        ordm = 186,     oslash = 248,  otilde = 245,   otimes = 8855,
        ouml = 246,     para = 182,    part = 8706,    permil = 8240,
        perp = 8869,    phi = 966,     pi = 960,       piv = 982,
        plusmn = 177,   pound = 163,   prime = 8242,   prod = 8719,
        prop = 8733,    psi = 968,     quot = 34,      rArr = 8658,
        radic = 8730,   rang = 9002,   raquo = 187,    rarr = 8594,
        rceil = 8969,   rdquo = 8221,  real = 8476,    reg = 174,
        rfloor = 8971,  rho = 961,     rlm = 8207,     rsaquo = 8250,
        rsquo = 8217,   sbquo = 8218,  scaron = 353,   sdot = 8901,
        sect = 167,     shy = 173,     sigma = 963,    sigmaf = 962,
        sim = 8764,     spades = 9824, sub = 8834,     sube = 8838,
        sum = 8721,     sup = 8835,    sup1 = 185,     sup2 = 178,
        sup3 = 179,     supe = 8839,   szlig = 223,    tau = 964,
        there4 = 8756,  theta = 952,   thetasym = 977, thinsp = 8201,
        thorn = 254,    tilde = 732,   times = 215,    trade = 8482,
        uArr = 8657,    uacute = 250,  uarr = 8593,    ucirc = 251,
        ugrave = 249,   uml = 168,     upsih = 978,    upsilon = 965,
        uuml = 252,     weierp = 8472, xi = 958,       yacute = 253,
        yen = 165,      yuml = 255,    zeta = 950,     zwj = 8205,
        zwnj = 8204,
    }
end)

function M.decode_xml(text)
    return text:gsub([=[&(%a-);]=], function(m)
        local codepoint = XML_DECODE_MAPPING()[m]
        if codepoint then
            return vim.fn.nr2char(codepoint)
        end
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
