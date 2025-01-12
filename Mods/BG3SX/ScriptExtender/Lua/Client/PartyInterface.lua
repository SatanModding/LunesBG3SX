-- TODO - fetch party on client by checking Entitities with component PartyMember (check if it includes summons)


PartyInterface = {}
PartyInterface.__index = PartyInterface
function UI:NewPartyInterface()
    local instance = setmetatable({
        --UI = self.ID,
        Wrapper = {},
        Party = {},
        NPCs = {},
    }, PartyInterface)
    self.Settings["PartyButtonSize"] = {100,100}
    return instance
end


function PartyInterface:Initialize()
    self.Wrapper = UIInstance.Window:AddGroup("")

    self.PartyArea = self.Wrapper:AddCollapsingHeader("Party")
    self.NPCArea = self.Wrapper:AddCollapsingHeader("NPCs")
    self.NPCArea.Visible = false

    UIEvents.FetchParty:SendToServer({ID = USERID})
end

function PartyInterface:UpdateParty()

    self.Characters = nil
    UI.DestroyChildren(self.PartyArea)

    local maxTableWidth = 4
    local tableWidth = math.min(#self.Party, maxTableWidth)  -- Take lower

    local t = self.PartyArea:AddTable("",tableWidth)
    t.SizingFixedFit = true
    t.NoHostExtendX = true
    t.Borders = true

    local row
    for i, character in ipairs(self.Party) do
        if i % maxTableWidth == 1 then
            row = t:AddRow()
        end 

        local newCharacter = self:AddCharacter(row, character[1])

        if i == 1 then
            self:SetSelectedCharacter(newCharacter.Uuid)
        end
    end
end

function PartyInterface:UpdateNPCs()
    if self.NPCs and #self.NPCs > 0 then
        self.NPCArea.Visible = true
    else
        self.NPCArea.Visible = false
    end
    
    self.CurrentNPCs = nil
    UI.DestroyChildren(self.NPCArea)

    local maxTableWidth = 4
    local tableWidth = math.min(#self.NPCs, maxTableWidth)  -- Take lower

    local t = self.NPCArea:AddTable("", tableWidth)
    t.SizingFixedFit = true
    t.NoHostExtendX = true
    t.Borders = true

    local row
    for i, npc in ipairs(self.NPCs) do
        if i % maxTableWidth == 1 then
            row = t:AddRow()
        end 

        local newNPC = self:AddNPC(row, npc)

        -- Set the selected character if it's the last one being added
        if i == #self.NPCs then
            self:SetSelectedCharacter(newNPC.Uuid)
        end
    end
end

function UI:SelectedCharacterUpdates(character)
    if self.Await and self.Await.Reason == "NewScene" then
        self:InputRecieved(character.Uuid)
    else
        local entity = Ext.Entity.Get(character.Uuid)
        self.PartyInterface:SetSelectedCharacter(character.Uuid)
        self.AppearanceTab:UpdateStrippingGroup(character.Uuid)
        -- self.AppearanceTab:UpdateToggleVisibilityGroup(character.Uuid)
        self.AppearanceTab:UpdateEquipmentAreaGroup(character.Uuid)
        self.AppearanceTab:FetchGenitals()
        UIEvents.FetchUserTags:SendToServer({ID = USERID, Character = character.Uuid})
        Camera:SnapCameraTo(entity)
    end
end

CharacterInterface = {}
CharacterInterface.__index = CharacterInterface
function PartyInterface:AddCharacter(parent, uuid)
    if not self.Characters then
        self.Characters = {}
    end
    local cell = parent:AddCell()

    local instance = setmetatable({
        Uuid = uuid,
        Name = Helper.GetName(uuid),
        CharacterButton = nil,
        NameText = nil,
        Selected = nil
    }, CharacterInterface)

    local foundOrigin
    for uuid,origin in pairs(Data.Origins) do
        if Helper.StringContains(uuid, instance.Uuid) then
            foundOrigin = true
            instance.CharacterButton = cell:AddImageButton("","EC_Portrait_"..origin, UIInstance.Settings["PartyButtonSize"])
        end
    end
    if not foundOrigin then
        instance.CharacterButton = cell:AddImageButton("","EC_Portrait_Generic", UIInstance.Settings["PartyButtonSize"])
    end

    instance.CharacterButton.OnClick = function()
        UIInstance:SelectedCharacterUpdates(instance)
    end

    instance.NameText = cell:AddText("")
    instance.NameText.Label = instance.Name

    table.insert(self.Characters, instance)
    return instance
end

NPCInterface = {}
NPCInterface.__index = NPCInterface
function PartyInterface:AddNPC(parent, uuid)
    if not self.CurrentNPCs then
        self.CurrentNPCs = {}
    end
    local parent = parent or nil
    local cell = parent:AddCell()

    local instance = setmetatable({
        Uuid = uuid,
        Name = Helper.GetName(uuid),
        CharacterButton = nil,
        NameText = nil,
        Selected = nil
    }, NPCInterface)

    local foundOrigin
    for uuid,origin in pairs(Data.Origins) do
        if Helper.StringContains(uuid, instance.Uuid) then
            foundOrigin = true
            instance.CharacterButton = cell:AddImageButton("","EC_Portrait_"..origin, UIInstance.Settings["PartyButtonSize"])
        end
    end
    if not foundOrigin then
        instance.CharacterButton = cell:AddImageButton("","EC_Portrait_Generic", UIInstance.Settings["PartyButtonSize"])
    end

    instance.CharacterButton.OnClick = function()
        UIInstance:SelectedCharacterUpdates(instance)
    end
    instance.DeleteButton = cell:AddButton("x")
    instance.DeleteButton.SameLine = true
    instance.DeleteButton.OnClick = function()
        for i,uuid in pairs(self.NPCs) do
            if uuid == uuid then
                table.remove(self.NPCs, i)
            end
        end
        -- self.CurrentNPCs = nil -- Will be rebuild with Update call
        self:UpdateNPCs()
    end

    instance.NameText = cell:AddText("")
    instance.NameText.Label = instance.Name


    table.insert(self.CurrentNPCs, instance)
    return instance
end

function UI.GetSelectedCharacter()
    -- Debug.Print("Selected Characer Is:")
    -- _D(self.PartyInterface.SelectedCharacter)
    return UIInstance.PartyInterface.SelectedCharacter.Uuid or _C().Uuid.EntityUuid
end

function PartyInterface:SetSelectedCharacter(characterUuid)
    local characterAndNPCs = {}
    if self.Characters and #self.Characters > 0 then
        for _,character in pairs(self.Characters) do
            table.insert(characterAndNPCs, character)
        end
    end
    if self.CurrentNPCs and #self.CurrentNPCs > 0 then
        for _,npc in pairs(self.CurrentNPCs) do
            table.insert(characterAndNPCs, npc)
        end
    end
    for _,charOrNPC in pairs(characterAndNPCs) do
        if Helper.StringContains(charOrNPC.Uuid, characterUuid) then
            charOrNPC.CharacterButton.Tint = {1.0, 0.8, 0.3, 1.0} -- Neutral Selected Color -- Beige
            charOrNPC.Selected = true
            self.SelectedCharacter = charOrNPC
            UIEvents.SetSelectedCharacter:SendToServer({ID = USERID, Uuid = charOrNPC.Uuid})
        else
            charOrNPC.CharacterButton.Tint = {1.0, 1.0, 1.0, 1.0} -- Reset to regular
            charOrNPC.Selected = false
        end
    end
end

-- Only one can be hovered at a time
function PartyInterface:GetHovered()
    if UIInstance.PartyInterface.Characters then 
        _P("1")
        for _,character in pairs(UIInstance.PartyInterface.Characters) do
            _P("2")
            if character.CharacterButton.Statusflags["HoveredRect"] then
                _P("3")
                return character
            end
        end
    end
        if UIInstance.PartyInterface.CurrenNPCs then 
        for _,npc in pairs(UIInstance.PartyInterface.CurrentNPCs) do
            if npc.CharacterButton.Statusflags["HoveredRect"] then
                return npc
            end
        end
    end
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

