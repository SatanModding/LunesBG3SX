-- TODO - fetch party on client by checking Entitities with component PartyMember (check if it includes summons)


PartyInterface = {}
PartyInterface.__index = PartyInterface
function UI:NewPartyInterface()
    local instance = setmetatable({
        --UI = self.ID,
        Wrapper = {},
        Party = {}
    }, PartyInterface)
    self.Settings["PartyButtonSize"] = {100,100}
    return instance
end


function PartyInterface:Initialize()
    self.Wrapper = UIInstance.Window:AddCollapsingHeader("Party")
    UIEvents.FetchParty:SendToServer({ID = USERID})
end

function PartyInterface:UpdateParty()
    local wrapper = self.Wrapper
    UI.DestroyChildren(wrapper)
    local tWidth = #self.Party
    self.PartyArea = wrapper:AddTable("",tWidth)
    local t = self.PartyArea
    _P("Witdth", tWidth)
    t.SizingFixedFit = true
    -- t.NoClip = true
    t.NoHostExtendX = true
    t.Borders = true
    -- self.PartyArea.ScrollX = true
    local row = t:AddRow()
    for i, character in ipairs(self.Party) do
        -- if i % tWidth == 0 then
        --     row = t:AddRow()
        -- end
        self:AddCharacter(character[1])
    end
end

CharacterInterface = {}
CharacterInterface.__index = CharacterInterface
function PartyInterface:AddCharacter(uuid)
    if not self.Characters then
        self.Characters = {}
    end
    local cell = self.PartyArea.Children[1]:AddCell()

    local instance = setmetatable({
        Uuid = uuid,
        Name = Helper.GetName(uuid),
        CharacterButton = nil,
        NameText = nil
    }, CharacterInterface)

    local foundOrigin
    for uuid,origin in pairs(Data.Origins) do
        if Helper.StringContains(uuid, instance.Uuid) then
            foundOrigin = true
            _P(foundOrigin)
            instance.CharacterButton = cell:AddImageButton("","EC_Portrait_"..origin, UIInstance.Settings["PartyButtonSize"])
        end
    end
    if not foundOrigin then
        instance.CharacterButton = cell:AddImageButton("","EC_Portrait_Generic", UIInstance.Settings["PartyButtonSize"])
    end

    instance.CharacterButton.OnClick = function()
        
    end

    instance.NameText = cell:AddText("")
    instance.NameText.Label = instance.Name

    table.insert(self.Characters, instance)
    return instance
end















function PartyInterface:AddSelectedNPCSection()
    
end


-- TODO:
-- Add Character Selection
---- For Genitals
---- For Scenes
---- For Whitelist
-- Add Party Update when characters join
-- Add Consent when targeting other players - withold scene creation until consent is given
-- Check Multiplayer




-- function UI.FindCharacterTable(uuid)
--     for _,entry in pairs(characterTables) do
--         if entry.uuid == uuid then
--             return entry.table
--         end
--     end
-- end

-- function UI.CharacterButton(table)
--     UI.HighlightOnlyOne(table, characterTables)
--     --DoSomethingElse
--     --Refresh Info in Tabs
-- end

-- function UI.AddCharacter(parent, uuid)
--     local character = Ext.Entity.Get(uuid)
--     local charTable = parent:AddCell():AddTable("", 1)
--     charTable.SizingStretchProp = true
--     --charTable.Borders = true
--     local row = charTable.AddRow()
--     local size = {100,100}
--     local tName = Ext.Loca.GetTranslatedString(character.DisplayName.NameKey.Handle.Handle)
--     local characterButton
--     local foundOrigin = false
--     for uuid,origin in pairs(Data.Origins) do
--         if Helper.StringContains(uuid, character.Uuid.EntityUuid) then
--             foundOrigin = true
--             characterButton = row:AddCell():AddImageButton("","EC_Portrait_"..origin, size)
--         end
--     end
--     if foundOrigin == false then
--         characterButton = row:AddCell():AddImageButton("","EC_Portrait_Generic", size)
--     end

--     characterButton.OnClick = function()
--         UI.CharacterButton(charTable)
--     end
--     --local infoArea = row:AddCell():AddTable("", 1)
--     local characterName = charTable.AddRow():AddCell():AddText("")
--     characterName.Label = tName
--     --local additionalInfo = infoArea:AddRow():AddCell():AddText("AdditionalInfoArea")
--     table.insert(characterTables, {uuid = uuid, table = charTable, button = characterButton})
--     return charTable
-- end


-- --TODO - Osi.DB_Partymembers not available on client
-- function UI.CreateCharacterTable(parent)
--     local charTable = parent:AddTable("characterTable", 4)
--     charTable.SizingStretchProp = true
--     --charTable.Borders = true
--     charTable.ScrollY = false
--     --charTable.ScrollX = true
--     local row = charTable.AddRow()
--     --row:AddCell():AddText("Test")
--     local characterCount = 0
--     local party = UIHelper.GetCurrentParty()
--     for _, uuid in pairs(party) do
--         if characterCount > 0 and characterCount % 4 == 0 then
--             row = charTable.AddRow()
--         end
--         --if Entity:IsWhitelisted(uuid, false) then
--             local companion = UI.AddCharacter(row, uuid)
--             characterCount = characterCount + 1
--         --end
--     end
--     return charTable
-- end


-- function UI.HighlightConnected(tableToHighlight, listOfTables)
--     for _,entry in pairs(listOfTables) do
--         if entry.table == tableToHighlight then
--             entry.table.Borders = true
--             -- Color it in a different color
--         end
--     end
-- end

-- function UI.HighlightOnlyOne(tableToHighlight, listOfTables)
--     --FailColor = {1.0, 0.0, 0.0, 1.0},
--     --SuccessColor = {0.0, 1.0, 0.0, 1.0},
--     --NeutralColor = {0.7, 0.7, 0.7, 1.0},
--     for _,entry in pairs(listOfTables) do
--         if entry.table == tableToHighlight then
--             entry.button.Tint = {1.0, 0.8, 0.3, 1.0} -- Neutral Selected Color -- Beige
--             entry.selected = true
--         else
--             entry.button.Tint = {1.0, 1.0, 1.0, 1.0} -- Reset to regular
--             entry.selected = false
--         end
--     end
-- end