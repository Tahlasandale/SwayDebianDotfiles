-- Compteur de mots et caracteres dans la barre de statut.
-- Appele depuis settings.json via $(initlua.wordcount)
--
-- SetStatusInfoFn attend un seul argument "plugin.fonction" et micro
-- appelle la fonction en lui passant le buffer courant.

local micro = import("micro")
local util = import("micro/util")
local utf8 = import("unicode/utf8")

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
        bp:HandleCommand("lsp autocomplete")
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
