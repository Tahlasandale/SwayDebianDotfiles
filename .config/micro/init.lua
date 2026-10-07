-- Raccourcis markdown : Alt-b gras, Alt-i italique, Alt-m lien.
-- Functions globales ici sont appelables depuis bindings.json via lua:initlua.<nom>.

local micro = import("micro")

local function wrap(bp, before, after, message)
    if not bp.Buf.HasSelection() then
        micro.InfoBar():Message(message)
        return false
    end
    local sel = bp.Buf:getSelection()
    bp.Buf:RemoveSelection()
    bp.Buf:InsertText(before .. sel .. after)
    return true
end

function bold(bp)
    return wrap(bp, "**", "**", "Gras : selectionne du texte d'abord")
end

function italic(bp)
    return wrap(bp, "*", "*", "Italique : selectionne du texte d'abord")
end

function linkify(bp)
    if not bp.Buf.HasSelection() then
        micro.InfoBar():Message("Lien : selectionne d'abord le libelle")
        return false
    end
    local sel = bp.Buf:getSelection()
    bp.Buf:RemoveSelection()
    bp.Buf:InsertText("[" .. sel .. "]()")
    bp.Buf:CursorLeft()
    return true
end
