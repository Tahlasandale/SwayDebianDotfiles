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

-- Order matters: detectPattern returns the first match, so a longer trigger must
-- come before any shorter trigger it contains ("![", before "[", "- [" before "[").
-- The code fence is not part of this table: it is triggered by a run of three or
-- more backticks, which is detected separately (see backtickRun).
local patterns = {
    { trigger = "**", insert = "****", description = "Bold text", cursorOffset = 2, skipIfNext = "**", skipIfOpenedBefore = true, option = "enableFormatting" },
    { trigger = "~~", insert = "~~~~", description = "Strikethrough", cursorOffset = 2, skipIfNext = "~~", skipIfOpenedBefore = true, option = "enableFormatting" },
    { trigger = "![", insert = "![]()", description = "Image", cursorOffset = 3, option = "enableFormatting" },
    { trigger = "`", insert = "``", description = "Inline code", cursorOffset = 1, skipIfNext = "`", onlyInlineContext = true, option = "enableFormatting" },
    { trigger = "- [", insert = "- [ ] ", description = "Checklist", cursorOffset = 0, option = "enableChecklists" },
    { trigger = "[", insert = "[]()", description = "Link", cursorOffset = 3, option = "enableFormatting" }
}

local fencePattern = { insert = "```\n\n```", description = "Code block", cursorOffset = 4, option = "enableCodeBlocks" }

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

-- Returns false to expand the snippet, true to ignore the trigger, or "close" when
-- the trigger is the closing delimiter of a pair that was already expanded (the
-- typed characters are then removed instead).
local function shouldSkipCompletion(bp, pattern, triggerLen)
    local cursor = bp.Cursor
    local line = bp.Buf:Line(cursor.Y)
    local column = cursor.X
    if pattern.skipIfNext then
        local ahead = string.sub(line, column + 1, column + #pattern.skipIfNext)
        if ahead == pattern.skipIfNext then
            -- The closing delimiter is already there: what was typed is redundant.
            return "close"
        end
    end
    -- Symmetric delimiters ("**", "~~", "`") are only expanded once per line: a
    -- later run is a closing delimiter that the user typed, not a new pair. Without
    -- this, typing "**bold**" turns into "**bold****".
    if pattern.skipIfOpenedBefore then
        local openedBefore = string.sub(line, 1, column - triggerLen)
        if openedBefore:find(pattern.trigger, 1, true) then
            return "close"
        end
    end
    if pattern.requireLineStart then
        local beforeTrigger = string.sub(line, 1, column - triggerLen)
        if beforeTrigger ~= "" and beforeTrigger:match("%S") then
            return true
        end
    end
    -- A backtick must only be paired when it really opens inline code: not when the
    -- line holds nothing but backticks (that is a code fence, and pairing would stop
    -- the run from ever reaching three) and not directly behind a word (that is the
    -- closing backtick the user is typing).
    if pattern.onlyInlineContext then
        local beforeTrigger = string.sub(line, 1, column - triggerLen)
        if beforeTrigger:match("^%s*`*$") then
            return true
        end
        local prevChar = string.sub(line, column - triggerLen, column - triggerLen)
        if prevChar:match("%w") then
            return true
        end
    end
    return false
end

-- Returns the number of consecutive backticks directly left of the cursor, which is
-- the run of backticks the user actually typed.
local function backtickRun(bp)
    local cursor = bp.Cursor
    local line = bp.Buf:Line(cursor.Y)
    local run = 0
    for i = cursor.X, 1, -1 do
        if string.sub(line, i, i) ~= "`" then
            break
        end
        run = run + 1
    end
    return run
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
    -- Three or more backticks open a code fence. The whole run is matched and
    -- replaced, otherwise the closing backtick of an inline code pair would be
    -- left in front of the fence.
    if getOption("enableCodeBlocks") then
        local run = backtickRun(bp)
        if run >= 3 then
            return fencePattern, run
        end
    end
    for _, pattern in ipairs(patterns) do
        if not pattern.option or getOption(pattern.option) then
            local triggerLen = #pattern.trigger
            if column >= triggerLen then
                local startPos = column - triggerLen + 1
                if startPos >= 1 then
                    local snippet = string.sub(line, startPos, column)
                    if snippet == pattern.trigger then
                        local skip = shouldSkipCompletion(bp, pattern, triggerLen)
                        if skip == "close" then
                            return pattern, triggerLen, "close"
                        end
                        if not skip then
                            return pattern, triggerLen
                        end
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

-- The user typed the closing delimiter of a pair this plugin already expanded. The
-- pair is complete, so the typed run is simply removed again and the cursor ends up
-- after the delimiter: "**bold**" stays "**bold**" instead of "**bold****".
local function closeTrigger(bp, triggerLen)
    for _ = 1, triggerLen do
        bp:Backspace()
    end
end

-- onRune runs after the rune has been inserted, so the typed character sits at
-- cursor.X - 1, cursor.X is the character right after it, and cursor.X - 1 is
-- the character before it.
local function handleAutoPair(bp, rune)
    if not getOption("enableAutoPairs") then
        return
    end
    -- Micro hands the rune to Lua as a one character string; older versions pass
    -- a number. Accept both, otherwise the pairing silently never happens.
    local char = rune
    if type(char) == "number" then
        char = string.char(char)
    end
    if type(char) ~= "string" or char == "" then
        return
    end
    local cursor = bp.Cursor
    local line = bp.Buf:Line(cursor.Y)
    local nextChar = string.sub(line, cursor.X + 1, cursor.X + 1)
    local prevChar = string.sub(line, cursor.X - 1, cursor.X - 1)
    for _, pair in ipairs(autoPairs) do
        if char == pair.close then
            -- The closer already exists further right: drop the typed duplicate
            -- and step over the existing one.
            if nextChar == pair.close then
                bp:Backspace()
                cursor:Right()
                return
            end
            -- The pair is already complete: step back inside it instead of
            -- appending a second closer.
            if prevChar == pair.open then
                cursor:Left()
                return
            end
            -- Keep apostrophes and quotes inside a word intact (don't, he's).
            if prevChar:match("%w") then
                return
            end
        end
        if char == pair.open then
            -- Do not pair when a word follows, the closer would end up in front
            -- of it.
            if nextChar:match("%w") then
                return
            end
            -- Do not pair when the closer is already there.
            if nextChar == pair.close then
                return
            end
            -- An identical opener is already there: step over it.
            if nextChar == pair.open then
                cursor:Right()
                return
            end
            bp.Buf:Insert(cursorLoc(bp), pair.close)
            cursor:Left()
            return
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

-- The link and image snippets expand to "[]()" / "![]()". Typing the closing "]" by
-- hand must not leave a stray bracket, and it should move the cursor to the place
-- the target belongs, so "[", "label", "]" puts the cursor between the parentheses.
local function handleSnippetCloser(bp, rune)
    if not getOption("enableFormatting") then
        return false
    end
    local char = rune
    if type(char) == "number" then
        char = string.char(char)
    end
    if type(char) ~= "string" then
        return false
    end
    local cursor = bp.Cursor
    local line = bp.Buf:Line(cursor.Y)
    local ahead = string.sub(line, cursor.X + 1, cursor.X + 1)
    if (char == "]" or char == ")") and (ahead == "]" or ahead == ")") then
        bp:Backspace()
        -- Walk over the closing bracket and the opening parenthesis of the snippet.
        for _ = 1, 2 do
            line = bp.Buf:Line(cursor.Y)
            local next_ = string.sub(line, cursor.X + 1, cursor.X + 1)
            if next_ ~= "]" and next_ ~= "(" then
                break
            end
            cursor:Right()
        end
        return true
    end
    return false
end

function onRune(bp, rune)
    if not isMarkdownFile(bp) then
        return true
    end
    local pattern, triggerLen, action = detectPattern(bp)
    if pattern then
        if action == "close" then
            closeTrigger(bp, triggerLen)
        else
            insertCompletion(bp, pattern, triggerLen)
        end
        return true
    end
    if handleSnippetCloser(bp, rune) then
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
