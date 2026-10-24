-- Compteur de mots et caracteres dans la barre de statut.
-- Appele depuis settings.json via $(initlua.wordcount)
--
-- SetStatusInfoFn attend un seul argument "plugin.fonction" et micro
-- appelle la fonction en lui passant le buffer courant.

local micro = import("micro")
local util = import("micro/util")
local utf8 = import("unicode/utf8")

local typstWords = {
    -- Fonctions avec options ET contenu ()[]
    "align()[]", "figure()[]", "move()[]", "pad()[]", "place()[]",
    "quote()[]", "rotate()[]", "scale()[]", "slide()[]", "focus-slide()[]",

    -- Fonctions de contenu avec crochets []
    "block[]", "block()", "box[]", "box()", "heading[]", "heading()",
    "highlight[]", "underline[]", "strike[]", "emph[]", "strong[]",
    "footnote[]", "rect[]", "rect()", "circle[]", "circle()",
    "square[]", "square()", "ellipse[]", "ellipse()", "text[]", "text()[]",

    -- Fonctions avec parenthèses ()
    "assert()", "bibliography()", "calc", "cite()", "colbreak()",
    "columns()", "counter()", "datetime()", "document()", "eval()",
    "grid()", "image()", "import", "include", "layout()", "line()",
    "linebreak()", "link()", "list()", "lorem()", "measure()",
    "metadata()", "numbering()", "outline()", "page()", "pagebreak()",
    "panic()", "par()", "parbreak()", "path()", "polygon()", "query()",
    "raw()", "ref()", "regex()", "repeat()", "return", "selector()",
    "set", "show", "stack()", "state()", "table()", "v()", "h()", "pause"
}

local function completeTypstFallback(bp, stem)
    local completions = {}
    local labels = {}
    local seen = {}
    for _, word in ipairs(typstWords) do
        local base = word:match("^([%w_-]+)")
        if base and string.find(base, stem, 1, true) == 1 then
            if not seen[word] then
                seen[word] = true
                table.insert(labels, word)
                table.insert(completions, string.sub(word, #stem + 1))
            end
        end
    end
    if #completions > 0 then
        local completer = function() return completions, labels end
        bp.Buf:Autocomplete(completer)
        if #completions == 1 then
            local cur = bp.Cursor
            local curLine = bp.Buf:Line(cur.Y)
            local curCol = cur.X
            if curCol >= 4 and curLine:sub(curCol - 3, curCol) == "()[]" then
                cur:Left()
                cur:Left()
                cur:Left()
            elseif curCol >= 2 then
                local tail = curLine:sub(curCol - 1, curCol)
                if tail == "()" or tail == "[]" or tail == '""' then
                    cur:Left()
                end
            end
        end
        return true
    end
    return false
end

function init()
    micro.SetStatusInfoFn("initlua.wordcount")
end

function smartTab(bp)
    if bp.Cursor:HasSelection() then
        bp:IndentSelection()
        return
    end

    local cursor = bp.Cursor
    local line = bp.Buf:Line(cursor.Y)
    local col = cursor.X
    local textBefore = string.sub(line, 1, col)

    if textBefore:match("^%s*$") then
        bp:InsertTab()
        return
    end

    if bp.Buf.HasSuggestions then
        bp:Autocomplete()
        return
    end

    local ft = bp.Buf:FileType()
    if ft == "typst" then
        local wordbytes, _ = bp.Buf:GetWord()
        local stem = util.String(wordbytes)

        -- Si précédé de #, interroger le serveur LSP en priorité
        if textBefore:match("#[%w_-]*$") then
            bp:HandleCommand("lsp autocomplete")
        else
            -- Si tapé sans # (ex: "pagebreak", "outline"), compléter directement via le dictionnaire Typst
            if not completeTypstFallback(bp, stem) then
                if not bp:Autocomplete() then
                    bp:InsertTab()
                end
            end
        end
    else
        if not bp:Autocomplete() then
            bp:InsertTab()
        end
    end
end

function wordcount(b)
    local text = util.String(b:Bytes())
    local _, words = text:gsub("%S+", "")
    local chars = utf8.RuneCountInString(text)
    return string.format("%d mots, %d car.", words, chars)
end
