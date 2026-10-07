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

function wordcount(b)
    local text = util.String(b:Bytes())
    local _, words = text:gsub("%S+", "")
    local chars = utf8.RuneCountInString(text)
    return string.format("%d mots, %d car.", words, chars)
end
