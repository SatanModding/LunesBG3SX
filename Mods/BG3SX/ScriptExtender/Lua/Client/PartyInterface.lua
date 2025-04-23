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
    self.Settings["PartyButtonSize"] = {100*ViewPortScale,100*ViewPortScale}
    return instance
end


function PartyInterface:Initialize()
    self.Wrapper = UIInstance.Window:AddGroup("")

    self.PartyArea = self.Wrapper:AddCollapsingHeader("Party")
    self.NPCArea = self.Wrapper:AddCollapsingHeader("NPCs")
    self.NPCArea.Visible = false

    Event.FetchParty:SendToServer({ID = USERID})
end

function PartyInterface:UpdateParty()
    -- _D(self.Party)
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
    self.CurrentNPCs = nil
    UI.DestroyChildren(self.NPCArea)
    if self.NPCs and #self.NPCs > 0 then
        self.NPCArea.Visible = true
    else
        self.NPCArea.Visible = false
        self:SetSelectedCharacter(self.Party[1][1])
        return
    end
    
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
        Event.FetchUserTags:SendToServer({ID = USERID, Character = character.Uuid})
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
    
    instance.Popup = cell:AddPopup("NPCPopup")
    instance.Popup.IDContext = math.random(1000,100000)
    instance.CharacterButton.OnClick = function()
        if not UIInstance.Await then
            instance.Popup:Open()
        else
            UIInstance:SelectedCharacterUpdates(instance)
        end
    end

    local selectNPC = instance.Popup:AddSelectable(Ext.Loca.GetTranslatedString("h2a86e31d7ec34b7490ead80f174354da5726", "Select"))
    selectNPC.OnClick = function()
        selectNPC.Selected = false
        UIInstance:SelectedCharacterUpdates(instance)
    end

    local removeNPC = instance.Popup:AddSelectable(Ext.Loca.GetTranslatedString("hbf2bfd2e408c493d9580e1fa08b7782d502g", "Remove"))
    removeNPC.OnClick = function()
        removeNPC.Selected = false
        -- instance.Popup:Close()
        for i,npcUuid in pairs(self.NPCs) do
            if npcUuid == uuid then
                table.remove(self.NPCs, i)
                Event.RemovedNPCFromTab:SendToServer({ID=USERID, npc = uuid})
            end
        end
        self:UpdateNPCs()
    end

    instance.NameText = cell:AddText("")
    instance.NameText.Label = instance.Name

    table.insert(self.CurrentNPCs, instance)
    return instance
end

function PartyInterface:SetSelectedCharacter(characterUuid)
    -- _P("SetSelectedCharacter called with uuid: " .. characterUuid)
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
            _P("Selected character: " .. charOrNPC.Uuid)
            -- Event.SetSelectedCharacter:SendToServer({ID = USERID, Uuid = charOrNPC.Uuid})
        else
            charOrNPC.CharacterButton.Tint = {1.0, 1.0, 1.0, 1.0} -- Reset to regular
            -- _P("Resetting tint to regular for character: " .. charOrNPC.Uuid)
            charOrNPC.Selected = false
        end
    end

    Event.RequestWhitelistStatus:SendToServer({ID = USERID, Uuid = characterUuid})
    print("Selected character persistance check ", self.SelectedCharacter.Uuid)
end

-- Event.SetSelectedCharacter:SetHandler(function (payload)
    -- Empty Handler currently to avoid console prints
    -- Todo: Do something with it
    -- local x = payload
-- end)

-- Only one can be hovered at a time
function PartyInterface:GetHovered()
    if UIInstance.PartyInterface.Characters then 
        -- _P("1")
        for _,character in pairs(UIInstance.PartyInterface.Characters) do
            -- _P("2")
            if character.CharacterButton.Statusflags["HoveredRect"] then
                -- _P("3")
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
-- Add Consent when targeting other players - withold scene creation until consent is given
-- Check Multiplayer