-- Markdown Autocomplete Plugin for Micro Editor
-- Provides intelligent autocompletion for Markdown syntax

VERSION = "1.1.0"

local micro = import("micro")
local buffer = import("micro/buffer")
local config = import("micro/config")

local pluginName = "markdown_autocomplete"

local defaultOptions = {
    enableFormatting = true,
    enableCodeBlocks = true,
    enableChecklists = true,
    enableAutoPairs = true,
    enableLists = true,
    enableListCleanup = true,
    showMessages = false,
}

local validOptions = {}
for key in pairs(defaultOptions) do
    validOptions[key] = true
end

local function log(message)
    micro.Log(string.format("[%s] %s", pluginName, message))
end

local function qualifiedOption(name)
    return string.format("%s.%s", pluginName, name)
end

local function getOption(name)
    local ok, value = pcall(config.GetGlobalOption, qualifiedOption(name))
    if ok and value ~= nil then
        return value
    end
    return defaultOptions[name]
end

local function setOption(name, value)
    if not validOptions[name] then
        return false, string.format("Unknown option '%s'", name)
    end
    local ok, err = pcall(config.SetGlobalOptionNative, qualifiedOption(name), value)
    if not ok then
        return false, err
    end
    return true
end

local function toggleOption(name)
    local newValue = not getOption(name)
    local ok, err = setOption(name, newValue)
    if not ok then
        return nil, err
    end
    return newValue
end

local function notify(message)
    if getOption("showMessages") then
        micro.InfoBar():Message(message)
    end
    log(message)
end

local function cursorLoc(bp)
    return -bp.Cursor.Loc
end

local patterns = {
    { trigger = "**", insert = "****", description = "Bold text", cursorOffset = 2, skipIfNext = "**", option = "enableFormatting" },
    { trigger = "~~", insert = "~~~~", description = "Strikethrough", cursorOffset = 2, skipIfNext = "~~", option = "enableFormatting" },
    { trigger = "![", insert = "![]()", description = "Image", cursorOffset = 3, option = "enableFormatting" },
    { trigger = "[", insert = "[]()", description = "Link", cursorOffset = 3, option = "enableFormatting" },
    { trigger = "`", insert = "``", description = "Inline code", cursorOffset = 1, skipIfNext = "`", option = "enableFormatting" },
    { trigger = "```", insert = "```\n\n```", description = "Code block", cursorOffset = 4, option = "enableCodeBlocks" },
    { trigger = "- [", insert = "- [ ] ", description = "Checklist", cursorOffset = 0, option = "enableChecklists" }
}

local autoPairs = {
    { open = "(", close = ")" },
    { open = "{", close = "}" },
    { open = "\"", close = "\"" },
    { open = "'", close = "'" }
}

local function isMarkdownFile(bp)
    local ft = bp.Buf:FileType()
    if ft == "markdown" or ft == "md" then
        return true
    end
    local name = bp.Buf:GetName()
    if name and (name:match("%.md$") or name:match("%.markdown$")) then
        return true
    end
    return false
end

local function shouldSkipCompletion(bp, pattern, triggerLen)
    local cursor = bp.Cursor
    local line = bp.Buf:Line(cursor.Y)
    local column = cursor.X
    if pattern.skipIfNext then
        local ahead = string.sub(line, column + 1, column + #pattern.skipIfNext)
        if ahead == pattern.skipIfNext then
            return true
        end
    end
    if pattern.requireLineStart then
        local beforeTrigger = string.sub(line, 1, column - triggerLen)
        if beforeTrigger ~= "" and beforeTrigger:match("%S") then
            return true
        end
    end
    return false
end

local function detectPattern(bp)
    if not isMarkdownFile(bp) then
        return nil
    end
    local cursor = bp.Cursor
    local line = bp.Buf:Line(cursor.Y)
    local column = cursor.X
    if column == 0 then
        return nil
    end
    for _, pattern in ipairs(patterns) do
        if not pattern.option or getOption(pattern.option) then
            local triggerLen = #pattern.trigger
            if column >= triggerLen then
                local startPos = column - triggerLen + 1
                if startPos >= 1 then
                    local snippet = string.sub(line, startPos, column)
                    if snippet == pattern.trigger and not shouldSkipCompletion(bp, pattern, triggerLen) then
                        return pattern, triggerLen
                    end
                end
            end
        end
    end
    return nil
end

local function insertCompletion(bp, pattern, triggerLen)
    for _ = 1, triggerLen do
        bp:Backspace()
    end
    bp.Buf:Insert(cursorLoc(bp), pattern.insert)
    local offset = pattern.cursorOffset or 0
    for _ = 1, offset do
        bp.Cursor:Left()
    end
end

local function handleAutoPair(bp, rune)
    if not getOption("enableAutoPairs") then
        return
    end
    local ok, char = pcall(string.char, rune)
    if not ok or not char then
        return
    end
    for _, pair in ipairs(autoPairs) do
        if char == pair.open then
            bp.Buf:Insert(cursorLoc(bp), pair.close)
            bp.Cursor:Left()
            break
        end
    end
end

local function clearListMarker(bp, lineIndex)
    if not getOption("enableListCleanup") then
        return
    end
    local text = bp.Buf:Line(lineIndex)
    if not text or text == "" then
        return
    end
    bp.Buf:Replace(buffer.Loc(0, lineIndex), buffer.Loc(#text, lineIndex), "")
end

local function continueNumberedList(bp, prevLine)
    local indent, digits = prevLine:match("^(%s*)(%d+)%.")
    if not digits then
        return false
    end
    local nextNum = tonumber(digits) + 1
    bp.Buf:Insert(cursorLoc(bp), string.format("%s%d. ", indent, nextNum))
    return true
end

local function continueBulletList(bp, prevLine)
    local indent, marker = prevLine:match("^(%s*)([-*+])%s+")
    if not marker then
        indent, marker = prevLine:match("^(%s*)([-*+])%s*$")
    end
    if not marker then
        return false
    end
    bp.Buf:Insert(cursorLoc(bp), string.format("%s%s ", indent, marker))
    return true
end

local function handleListContinuation(bp)
    if not getOption("enableLists") then
        return
    end
    local cursor = bp.Cursor
    local lineIndex = cursor.Y
    if lineIndex <= 0 then
        return
    end
    local prevLine = bp.Buf:Line(lineIndex - 1)
    if not prevLine then
        return
    end
    if (prevLine:match("^%s*[-*+]%s*$") or prevLine:match("^%s*%d+%.%s*$")) and getOption("enableListCleanup") then
        clearListMarker(bp, lineIndex - 1)
        return
    end
    if continueNumberedList(bp, prevLine) then
        return
    end
    continueBulletList(bp, prevLine)
end

local function parseBoolean(value)
    local lowered = string.lower(value)
    if lowered == "true" or lowered == "1" or lowered == "on" or lowered == "yes" then
        return true
    elseif lowered == "false" or lowered == "0" or lowered == "off" or lowered == "no" then
        return false
    end
    return nil
end

local function toggleMessagesCommand(bp, args)
    local newValue, err = toggleOption("showMessages")
    if newValue == nil then
        micro.InfoBar():Error(err or "Unable to toggle messages")
        return
    end
    local status = newValue and "enabled" or "disabled"
    micro.InfoBar():Message(string.format("Markdown autocomplete messages %s", status))
end

local function setOptionCommand(bp, args)
    if not args or #args < 2 then
        micro.InfoBar():Error("Usage: markdown-autocomplete-set <option> <true|false>")
        return
    end
    local option = args[1]
    local rawValue = args[2]
    if not validOptions[option] then
        micro.InfoBar():Error(string.format("Unknown option '%s'", option))
        return
    end
    local parsed = parseBoolean(rawValue)
    if parsed == nil then
        micro.InfoBar():Error("Value must be true/false, on/off, yes/no, or 1/0")
        return
    end
    local ok, err = setOption(option, parsed)
    if not ok then
        micro.InfoBar():Error(err or "Could not update option")
        return
    end
    micro.InfoBar():Message(string.format("%s=%s", option, tostring(parsed)))
end

local function statusCommand(bp, args)
    local parts = {}
    for key in pairs(defaultOptions) do
        parts[#parts + 1] = string.format("%s=%s", key, tostring(getOption(key)))
    end
    table.sort(parts)
    micro.InfoBar():Message(table.concat(parts, ", "))
end

function onRune(bp, rune)
    if not isMarkdownFile(bp) then
        return true
    end
    local pattern, triggerLen = detectPattern(bp)
    if pattern then
        insertCompletion(bp, pattern, triggerLen)
        return true
    end
    handleAutoPair(bp, rune)
    return true
end

function onInsertNewline(bp)
    if not isMarkdownFile(bp) then
        return true
    end
    handleListContinuation(bp)
    return true
end

function init()
    for key, value in pairs(defaultOptions) do
        config.RegisterCommonOption(pluginName, key, value)
    end
    notify("init() called")
    config.MakeCommand("markdown-autocomplete-toggle", toggleMessagesCommand, config.NoComplete)
    config.MakeCommand("markdown-autocomplete-set", setOptionCommand, config.NoComplete)
    config.MakeCommand("markdown-autocomplete-status", statusCommand, config.NoComplete)
    config.AddRuntimeFile(pluginName, config.RTHelp, "help/markdown-autocomplete.md")
end
