-- Dwarvenizer/Trollizer
-- An addon for World of Warcraft, the last great PC game

-- If you're Alliance:
-- Translates/mutilates your written word into something Flintlocke could've 
-- typed. Oh aye!

-- If you're Horde:
-- Translates/mutilates your written word into something Sen'jin could've 
-- carved in a stone. Ya, mon!

-- I've tried to incorporate some randomness; play around with
-- it a bit, type the same thing a few times, and you'll see what I mean.

-- Example (Dwarvenizer): 
--      "Ah, Loch Modan. Always a great sight for my old eyes. Everything so 
--      neat and tidy, and the few beasts around here... we'll be taking care
--      of them in no time."
-- ...becomes...
--      "Ah, Loch Modan. Always a great sight for me ol' eyes. Ev'rythin' so
--      neat and tidy, an' tha few beasts around 'ere... we'll be takin' care
--      o' them in no time."

-- Your mileage may vary, depending on your Dwarvenizer/Trollizer settings and 
-- randomness.

-- Also, I clearly consider this an RP enhancement addon. If you can't or 
-- don't type straight, it won't do you much good anyways.

-- Works in every private, local or group channel (say, whisper, party, guild
-- etc.) and numbered standard channels (general, trade etc.) from 1 to 4.
-- If a line starts with "((", it is considered OOC and left alone. If you
-- want to change the channel settings, type "/dwarvenizer toggle" or
-- "/trollizer toggle".

-- When it's first loaded, it's in Dwarvenizer mode. To switch, type 
-- "/trollizer". If you want to switch back, type "/dwarvenizer".

-- For options and (somewhat sparse) in-game help, type "/dwarvenizer" or 
-- "/trollizer".

-- Written by Param of Steamwheedle Cartel (EU).
--      Coin donations welcome!
--      carlo@zottmann.org

-- $Id: Dwarvenizer.lua 347 2007-04-15 12:20:57Z carlo $

---------------------------------------------------------------------------
-- Like roleplaying? For more "lazy man" RP goodness, give RPHelper a spin: 
-- http://www.curse-gaming.com/mod.php?addid=3041
---------------------------------------------------------------------------



Dwarvenizer = {
    version = "1.10";
    
    settingsID = UnitName('player') .. "@" .. GetRealmName();
    
    languages = {
        dwarf = DwarvenizerLangDwarven;
        troll = DwarvenizerLangTrollish;
    }
}



-----------------------------------------------------------------------------



Dwarvenizer.dwarvenize = function(messageIn)
    local messageOut = ""
    local language = Dwarvenizer.languages[ DwarvenizerSettings[Dwarvenizer.settingsID].language ]
    local itemLink
    local cnt = 0
    local replacements = {}
    
    -- Find, store and replace item links
    -- for itemLink in string.gmatch(messageIn, "(|c%x+|Hitem:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+|h%[.-%]|h|r)") do
    --     messageIn = string.gsub(messageIn, "|c%x+|Hitem:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+|h%[.-%]|h|r", "__"..cnt.."__", 1)
    --     table.insert(replacements, cnt, itemLink)
    --     cnt = cnt + 1
    -- end

    messageIn = string.gsub(messageIn, "(|c.*|r)", function (itemLink)
    		cnt = cnt + 1
	    	table.insert(replacements, cnt, itemLink)
	    	return "__"..cnt.."__"
	    end
	)

    -- Replace phrases
    table.foreachi(language.dict1,
        function(k, srSet)
            local stringSearch
            local stringReplace

            table.foreach(srSet, function(setKey, setValue) stringSearch, stringReplace = setKey, setValue; end)

            stringReplace = Dwarvenizer.adjustReplaceString(stringReplace)
            if (stringReplace ~= nil) then
                stringReplace = string.gsub(stringReplace, "[§@]+%s*$", "")
                -- messageIn = Dwarvenizer.translate(messageIn, "%s+" .. stringSearch .. "%s+", stringReplace)
                messageIn = Dwarvenizer.translate(messageIn, "%s+" .. stringSearch .. "%s+", " " .. stringReplace .. " ")
            end
        end
    )

    local lastSegment = ""

    -- Split input line into segments
    for segment in string.gmatch(messageIn, "[%p%a%d_ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮ]+") do
        local punctuation = ""

        for p in string.gmatch(segment, "(%p+)$") do punctuation = p; break; end
        if (punctuation == nil) then punctuation = ""; end

        segment = string.gsub(segment, "%p*$", "")

        -- Replace segments (i.e. words)
        table.foreachi(language.dict2,
            function(k, srSet)
                local stringSearch
                local stringReplace

                table.foreach(srSet, function(setKey, setValue) stringSearch, stringReplace = setKey, setValue; end)
                local punctuation = ""

                if (not (string.find(stringSearch, "^%^") and string.find(lastSegment, "'$"))) then
                    stringReplace = Dwarvenizer.adjustReplaceString(stringReplace)
                    if (stringReplace ~= nil) then
                        stringReplace = string.gsub(stringReplace, "[§@]+%s*$", "")
                        segment = Dwarvenizer.translate(segment, stringSearch, stringReplace)
                    end
                end
            end
        )
        
        -- Minor segment cleanup
        segment = string.gsub(segment, "´´", "´")
        
        lastSegment = segment
        messageOut = messageOut .. segment .. punctuation .. " "
    end

    -- Find item link placeholders and replace them with the actual item links, foo!
    table.foreachi(replacements, 
        function (k, v)
            messageOut = string.gsub(messageOut, "__"..k.."__", v, 1)
        end
    )

    return messageOut
end


    
Dwarvenizer.adjustReplaceString = function(stringReplace) 
    local wtfIsUpWithMathRandom = math.random(100)
    local chance = math.random(100)

    if (type(stringReplace) == "table") then
        local possibilities = {}

        table.foreach(stringReplace, function(k, v) table.insert(possibilities, v) end)

        stringReplace = possibilities[ math.random(table.getn(possibilities)) ]
    end
    
    if (DwarvenizerSettings[Dwarvenizer.settingsID].chance < 10) then
        if (string.sub(stringReplace, -2) == "§" and chance > (DwarvenizerSettings[Dwarvenizer.settingsID].chance * 10)) then
            return nil
        end

        if (string.sub(stringReplace, -2) == "@" and chance > (DwarvenizerSettings[Dwarvenizer.settingsID].chance * 5)) then
            return nil
        end
    end
    
    return stringReplace
end
    
    
    
Dwarvenizer.translate = function(segment, stringSearch, stringReplace)
    if (not string.find(segment, "^[%u]+$")) then
        segment = string.gsub(segment, stringSearch, stringReplace)

        if (stringSearch ~= "^he") then
            stringSearch1 = string.gsub(stringSearch, "%l", string.upper, 1)
            stringReplace1 = string.gsub(stringReplace, "%l", string.upper, 1)
            segment = string.gsub(segment, stringSearch1, stringReplace1)
        end
    end

    return segment
end



-----------------------------------------------------------------------------



Dwarvenizer.print = function(message)
    if (not string.find(message, "\n$")) then message = message .. "\n" end
    
    for line in string.gmatch(message, "(.-)\n") do
        DEFAULT_CHAT_FRAME:AddMessage(line)
    end
end



-----------------------------------------------------------------------------



Dwarvenizer.onSlashCommand = {}

Dwarvenizer.onSlashCommand.Dwarf = function(slashCommand)
    DwarvenizerSettings[Dwarvenizer.settingsID].language = "dwarf"
    Dwarvenizer.onSlashCommand._main(slashCommand)
end

Dwarvenizer.onSlashCommand.Troll = function(slashCommand)
    DwarvenizerSettings[Dwarvenizer.settingsID].language = "troll"
    Dwarvenizer.onSlashCommand._main(slashCommand)
end

Dwarvenizer.onSlashCommand._main = function(slashCommand)
    local language = Dwarvenizer.languages[ DwarvenizerSettings[Dwarvenizer.settingsID].language ]
    local chance = DwarvenizerSettings[Dwarvenizer.settingsID].chance
    slashCommand = string.lower(slashCommand)

    defaultMessage = language.name .. ": " .. language.welcomeMsg .. "\n    Type '/" .. language.slashCommand .. " chance <probability>', probability being the chance of " .. language.name .. " mangling your words, ranging from 0 (off) to 10 (painful, errm, full immersion)\n    Current chance: " .. DwarvenizerSettings[Dwarvenizer.settingsID].chance .. "\n    Type '/" .. language.slashCommand .. " toggle <channel type>' to enable/disable it for a particular channel type.\n    If you want to know which channels are enabled/disabled, type '/" .. language.slashCommand .. " toggle list'.\n    To switch between Dwarvenizer and Trollizer, type '/trollizer' instead of '/dwarvenizer' and vice versa -- arguments are the same.\n    Written by Param (A) of Steamwheedle Cartel (EU)"

    local meh1, meh2, chance = string.find(slashCommand, "%s*chance (%d+)")
    local meh1, meh2, toggle = string.find(slashCommand, "%s*toggle%s*(%a*)")

    if (chance) then
        chance = chance * 1;
        if (chance >= 0 and chance <= 10) then
            DwarvenizerSettings[Dwarvenizer.settingsID].chance = chance;
            
            Dwarvenizer.print(language.name .. ": Probability set to " .. chance .. "\n")
            
            if (chance == 0) then
                Dwarvenizer.print("    (It's turned off now.)\n")
            end
        else
            Dwarvenizer.print(language.name .. ": Probability must be a number between 0-10!\n")
        end


    elseif (toggle ~= "list" and toggle ~= "" and toggle ~= nil) then
        table.foreach(DwarvenizerSettings[Dwarvenizer.settingsID].system, 
            function(channel, bool)
                if (channel == string.lower(toggle)) then
                    DwarvenizerSettings[Dwarvenizer.settingsID].system[channel] = not DwarvenizerSettings[Dwarvenizer.settingsID].system[channel]

                    local state = "disabled"
                    if (DwarvenizerSettings[Dwarvenizer.settingsID].system[channel]) then state = "enabled" end
                    if (channel == "channel") then channel = "general chat" end
                    
                    Dwarvenizer.print(language.name .. ": " .. channel .. " channel processing " .. state)
                end
            end
        )

        
    elseif (toggle == "list" or toggle == "") then
        local togglesList = language.name .. " settings: "

        table.foreach(DwarvenizerSettings[Dwarvenizer.settingsID].system, 
            function(channel, bool)
                local state = "off"
                if (bool) then state = "on" end
                if (channel == "channel") then channel = "channel (i.e. general chat channels 1-4)" end
                togglesList = togglesList .. channel .. ": " .. state .. ", "
            end
        )
        
        togglesList = string.gsub(togglesList, ", $", ". ")

        Dwarvenizer.print(togglesList .. "To enable/disable " .. language.name .. " for a particular channel type, enter '/" .. language.slashCommand .. " toggle <channel type>', for example '/" .. language.slashCommand .. " toggle raid'. If you want to know which channels are enabled/disabled, type '/" .. language.slashCommand .. " toggle list'.")

    
    else
        Dwarvenizer.print(defaultMessage)
    end
end



-----------------------------------------------------------------------------



function Dwarvenizer_onLoad()
    math.randomseed(time())

    SLASH_Dwarvenizer_Dwarf1 = "/dwarvenizer"
    SlashCmdList["Dwarvenizer_Dwarf"] = Dwarvenizer.onSlashCommand.Dwarf

    SLASH_Dwarvenizer_Troll1 = "/trollizer"
    SlashCmdList["Dwarvenizer_Troll"] = Dwarvenizer.onSlashCommand.Troll

    if (DwarvenizerSettings == nil) then
        DwarvenizerSettings = {}
    end
    
    if (DwarvenizerSettings[Dwarvenizer.settingsID] == nil) then
        DwarvenizerSettings[Dwarvenizer.settingsID] = { chance = 8, version = Dwarvenizer.version, language = "dwarf" }
    end

    if (DwarvenizerSettings[Dwarvenizer.settingsID].system == nil) then
        DwarvenizerSettings[Dwarvenizer.settingsID].system = { say = true, whisper = true, channel = true, party = false, guild = false, yell = true, raid = false }
    end

    if (DwarvenizerSettings[Dwarvenizer.settingsID].language == nil) then
        DwarvenizerSettings[Dwarvenizer.settingsID].language = "dwarf"
    end
    
    if (DwarvenizerSettings[Dwarvenizer.settingsID].version == nil or DwarvenizerSettings[Dwarvenizer.settingsID].version < Dwarvenizer.version) then
        -- In case we'll ever need to update some user settings from one version to the next, we can do that here
        DwarvenizerSettings[Dwarvenizer.settingsID].version = Dwarvenizer.version
    end

    local name = Dwarvenizer.languages[ DwarvenizerSettings[Dwarvenizer.settingsID].language ].name
    local chance = DwarvenizerSettings[Dwarvenizer.settingsID].chance

    Dwarvenizer.print(name .. ": Loaded. Probability set to " .. chance .. " (out of 10). Have fun!\n")
end



-----------------------------------------------------------------------------



function Dwarvenizer_SendChatMessage(msg, system, language, channel)
    local systemSetToSay = false

    -- RPFilter seems to cause problems, resulting this method to throw errors. No idea what's going on.
    if (msg == nil) then
        msg = ""
    end
    
    if (system == nil) then
        system = "SAY"
        systemSetToSay = true
    end

    if (DwarvenizerSettings[Dwarvenizer.settingsID].chance > 0 and ((system == "CHANNEL" and channel > 0 and channel < 5) or system ~= "CHANNEL") and (not string.find(msg, "^%(%(")) and DwarvenizerSettings[Dwarvenizer.settingsID].system[string.lower(system)] == true and system ~= "EMOTE") then
        msg = Dwarvenizer.dwarvenize(msg)
    end

    if (systemSetToSay == true) then
        system = nil
    end

	-- Dwarvenizer.print("DWARVENIZER DEBUG: " .. msg)
    Dwarvenizer_Saved_SendChatMessage(msg, system, language, channel)
end



-- Inject the magic, David Copperbeard style
Dwarvenizer_Saved_SendChatMessage = nil;

if (SendChatMessage ~= Dwarvenizer_SendChatMessage) then
    Dwarvenizer_Saved_SendChatMessage = SendChatMessage;
    SendChatMessage = Dwarvenizer_SendChatMessage;
end

-- Carlo waz 'ere ...mon
