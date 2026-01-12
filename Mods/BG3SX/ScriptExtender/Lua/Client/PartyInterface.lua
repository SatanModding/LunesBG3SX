-- TODO - fetch party on client by checking Entitities with component PartyMember (check if it includes summons)

---@class PartyInterface
---@field Wrapper ExtuiGroup
---@field PartyArea ExtuiCollapsingHeader
---@field Party table
---@field NPCArea ExtuiCollapsingHeader
---@field NPCs table
---@field Characters table
---@field CurrentNPCs table
---@field SelectedCharacter string
---@field Init fun(self:PartyInterface)
---@field UpdateParty fun(self:PartyInterface)
---@field UpdateNPCs fun(self:PartyInterface)
---@field AddCharacter fun(self:PartyInterface, parent:ExtuiStyledRenderable, uuid:string):CharacterInterface
---@field AddNPC fun(self:PartyInterface, parent:ExtuiStyledRenderable, uuid:string):NPCInterface
---@field SetSelectedCharacter fun(self:PartyInterface, characterUuid:string)
---@field GetHovered fun(self:PartyInterface):CharacterInterface|NPCInterface|nil

PartyInterface = {}
PartyInterface.__index = PartyInterface

function PartyInterface:New(holder)
    local instance = setmetatable({
        Wrapper = holder:AddGroup("PartyInterfaceWrapper"),
        Party = {},
        NPCs = {},
    }, PartyInterface)
    return instance
end


function PartyInterface:Init()
    LocalSettings:AddOrChange("Party_Interface", { PartyButtonSize = 100*ViewPortScale })

    self.PartyArea = self.Wrapper:AddCollapsingHeader(Locale.GetTranslatedString("h9e956f29dc2c4233b14b0b07ac36c3f0d55c", "Party"))
    self.PartyArea.DefaultOpen = true
    self.NPCArea = self.Wrapper:AddCollapsingHeader(Locale.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs"))
    self.NPCArea.Visible = false

    -- Debug.Print("REQUESTING FETCHPARTY TO CLIENT WITH ID " .. USERID)
    Event.FetchParty:SendToServer({ID = USERID})
end

function PartyInterface:UpdateParty()
    local previouslySelectedUuid = self.SelectedCharacter and self.SelectedCharacter.Uuid or nil

    self.Characters = nil
    UI.DestroyChildren(self.PartyArea)

    local maxTableWidth = 4
    local tableWidth = math.min(#self.Party, maxTableWidth) -- Take lower

    local t = self.PartyArea:AddTable("",tableWidth) -- 1 was tableWidth
    t.SizingFixedFit = true
    t.NoHostExtendX = true

    local row = t:AddRow()
    local cell = row:AddCell()
    local ownedAvatarCharacter = nil
    local firstSelectableCharacter = nil
    local previouslySelectedCharacter = nil

    for i, character in ipairs(self.Party) do
        if i % maxTableWidth == 1 then
            row = t:AddRow()
            cell = row:AddCell()
        end

        local newCharacter = self:AddCharacter(cell, character[1])

        if newCharacter then
            -- Check if this is the previously selected character
            if previouslySelectedUuid and Helper.StringContains(newCharacter.Uuid, previouslySelectedUuid) then
                previouslySelectedCharacter = newCharacter
            end

            local canBeSelected = self:CanBeSelectedAsCaster(newCharacter.Uuid)

            -- Check if this is the current user's owned avatar (not an NPC)
            if canBeSelected and not Entity:IsNPC(newCharacter.Uuid) then
                local entity = Ext.Entity.Get(newCharacter.Uuid)
                local currentUserEntity = Ext.Entity.Get(USERID)

                if entity and entity.UserReservedFor and entity.UserReservedFor.UserID and
                   currentUserEntity and currentUserEntity.UserReservedFor and currentUserEntity.UserReservedFor.UserID then
                    if entity.UserReservedFor.UserID == currentUserEntity.UserReservedFor.UserID then
                        ownedAvatarCharacter = newCharacter
                    end
                end
            end

            -- First selectable character as fallback
            if not firstSelectableCharacter and canBeSelected then
                firstSelectableCharacter = newCharacter
            end
        end
    end

    -- Priority: previously selected (if still valid) > owned avatar > first selectable character
    if previouslySelectedCharacter and self:CanBeSelectedAsCaster(previouslySelectedCharacter.Uuid) then
        self:SetSelectedCharacter(previouslySelectedCharacter.Uuid)
    elseif ownedAvatarCharacter then
        self:SetSelectedCharacter(ownedAvatarCharacter.Uuid)
    elseif firstSelectableCharacter then
        self:SetSelectedCharacter(firstSelectableCharacter.Uuid)
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

    local t = self.NPCArea:AddTable("", tableWidth) -- 1 was tableWidth
    t.SizingFixedSame = true
    t.NoHostExtendX = true
    -- t.Borders = true

    local row = t:AddRow()
    for i, npc in ipairs(self.NPCs) do
        if i % maxTableWidth == 1 then
            row = t:AddRow()
        end

        local cell = row:AddCell()
        local newNPC = self:AddNPC(cell, npc)

        -- Set the selected character if it's the last one being added
        -- Could be made into a setting - Always select last added character
        if i == #self.NPCs then
            self:SetSelectedCharacter(newNPC.Uuid)
        end
    end
end

function UI:SelectedCharacterUpdates(character)
    if self.Await and (self.Await.Reason == "NewSFWScene" or self.Await.Reason == "NewNSFWScene") then
        self:InputRecieved(character.Uuid)
    else
        if not self.PartyInterface:CanBeSelectedAsCaster(character.Uuid) then
            self:DisplayInfoText(Locale.GetTranslatedString("h9f152ef66db44370a071fa550c420f29247c", "You can only control your own characters as initiators"), 3000)
            return
        end

        local entity = Ext.Entity.Get(character.Uuid)
        self.PartyInterface:SetSelectedCharacter(character.Uuid)

        self.AppearanceTab:UpdateStrippingGroup(character.Uuid)
        self.AppearanceTab:UpdateToggleVisibilityGroup(character.Uuid)
        self.AppearanceTab:UpdateEquipmentAreaGroup(character.Uuid)
        self.AppearanceTab:FetchGenitals()

        Event.FetchUserTags:SendToServer({ID = USERID, Character = character.Uuid})
        Camera:SnapCameraTo(entity)
    end
end

-- function PartyInterface:CheckIfAwaitingScenePartner()
--     if UI.Await and UI.Await.Reason == "NewScene" then
--         _P("Awaiting scene partner, checking for hovered entity")
--         self:AwaitInput()
--     else
--         _P("Not awaiting scene partner, no input needed")
--     end

--     mouseoverTarget = self.PartyInterface:GetHovered().Uuid or nil
--     if mouseoverTarget ~= nil then
--         self:InputRecieved(mouseoverTarget)
--     else
--         self:CancelAwaitInput("No entity found")
--     end
-- end

-- Helper to check if a character can be selected as a caster by the current user (e.g. not another player's avatar)
function PartyInterface:CanBeSelectedAsCaster(uuid)
    local entity = Ext.Entity.Get(uuid)
    if not entity then
        return false
    end

    -- NPCs can always be selected as casters
    if Entity:IsNPC(uuid) then
        return true
    end

    -- For player avatar characters, check ownership
    if entity.UserReservedFor and entity.UserReservedFor.UserID then
        local currentUserEntity = Ext.Entity.Get(USERID)
        if currentUserEntity and currentUserEntity.UserReservedFor and currentUserEntity.UserReservedFor.UserID then
            return entity.UserReservedFor.UserID == currentUserEntity.UserReservedFor.UserID
        end
    end

    return false
end

---@class CharacterInterface
CharacterInterface = {}
CharacterInterface.__index = CharacterInterface
function PartyInterface:AddCharacter(parent, uuid)
    if not self.Characters then
        self.Characters = {}
    end

    local parent = parent or nil
    if parent then

        local charGroup = parent:AddGroup("CharacterGroup_" .. uuid)
        charGroup.SameLine = true

        local instance = setmetatable({
            Uuid = uuid,
            Name = Helper.GetName(uuid),
            CharacterButton = nil, ---@class ExtuiImageButton
            NameText = nil,
            Selected = nil
        }, CharacterInterface)

        local foundOrigin
        for uuid,origin in pairs(Data.Origins) do
            if Helper.StringContains(uuid, instance.Uuid) then
                foundOrigin = true
                local defaultSize = 100*ViewPortScale
                local partyInterfaceSettings = LocalSettings:GetOr({ PartyButtonSize = defaultSize }, "Party_Interface")
                local buttonSize = type(partyInterfaceSettings) == "table" and partyInterfaceSettings.PartyButtonSize or defaultSize
                
                instance.CharacterButton = charGroup:AddImageButton("","EC_Portrait_"..origin, buttonSize)
            end
        end
        if not foundOrigin then
            local defaultSize = 100*ViewPortScale
            local partyInterfaceSettings = LocalSettings:GetOr({ PartyButtonSize = defaultSize }, "Party_Interface")
            local buttonSize = type(partyInterfaceSettings) == "table" and partyInterfaceSettings.PartyButtonSize or defaultSize
            instance.CharacterButton = charGroup:AddImageButton("","EC_Portrait_Generic", buttonSize)
        end

        instance.CharacterButton.OnClick = function()
            -- Check if awaiting a target selection
            if UI.Await and (UI.Await.Reason == "NewSFWScene" or UI.Await.Reason == "NewNSFWScene") then
                UI:SelectedCharacterUpdates(instance)
            else
                if self:CanBeSelectedAsCaster(instance.Uuid) then
                    UI:SelectedCharacterUpdates(instance)
                else
                    UI:DisplayInfoText(Locale.GetTranslatedString("h9f152ef66db44370a071fa550c420f29247c", "You can only control your own characters as initiators"), 3000)
                end
            end
        end

        instance.NameText = charGroup:AddText("")
        instance.NameText.Label = instance.Name

        table.insert(self.Characters, instance)
        return instance
    end
end

---@class NPCInterface
NPCInterface = {}
NPCInterface.__index = NPCInterface
function PartyInterface:AddNPC(parent, uuid)
    if not self.CurrentNPCs then
        self.CurrentNPCs = {}
    end

    local parent = parent or nil
        if parent then

        local npcGroup = parent:AddGroup("NPCGroup_" .. uuid)
        npcGroup.SameLine = true

        local instance = setmetatable({
            Uuid = uuid,
            Name = Helper.GetName(uuid),
            CharacterButton = nil, ---@class ExtuiImageButton
            NameText = nil,
            Selected = nil
        }, NPCInterface)

        local foundOrigin
        for uuid,origin in pairs(Data.Origins) do
            if Helper.StringContains(uuid, instance.Uuid) then
                foundOrigin = true
                local defaultSize = 100*ViewPortScale
                local partyInterfaceSettings = LocalSettings:GetOr({ PartyButtonSize = defaultSize }, "Party_Interface")
                local buttonSize = type(partyInterfaceSettings) == "table" and partyInterfaceSettings.PartyButtonSize or defaultSize
                instance.CharacterButton = npcGroup:AddImageButton("","EC_Portrait_"..origin, buttonSize)
            end
        end
        if not foundOrigin then
            local defaultSize = 100*ViewPortScale
            local partyInterfaceSettings = LocalSettings:GetOr({ PartyButtonSize = defaultSize }, "Party_Interface")
            local buttonSize = type(partyInterfaceSettings) == "table" and partyInterfaceSettings.PartyButtonSize or defaultSize
            instance.CharacterButton = npcGroup:AddImageButton("","EC_Portrait_Generic", buttonSize)
        end

        instance.Popup = npcGroup:AddPopup("NPCPopup")
        instance.Popup.IDContext = math.random(1000,100000)
        instance.CharacterButton.OnClick = function()
            if not UI.Await then
                instance.Popup:Open()
            else
                UI:SelectedCharacterUpdates(instance)
            end
        end

        local selectNPC = instance.Popup:AddSelectable(Locale.GetTranslatedString("h2a86e31d7ec34b7490ead80f174354da5726", "Select"))
        selectNPC.OnClick = function()
            selectNPC.Selected = false
            UI:SelectedCharacterUpdates(instance)
        end

        local removeNPC = instance.Popup:AddSelectable(Locale.GetTranslatedString("hbf2bfd2e408c493d9580e1fa08b7782d502g", "Remove"))
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

        instance.NameText = npcGroup:AddText("")
        instance.NameText.Label = instance.Name

        table.insert(self.CurrentNPCs, instance)
        return instance
    end
end

function PartyInterface:SetSelectedCharacter(characterUuid)
    -- Check if the character can be selected as caster (unless already targeting)
    if not UI.Await then
        local canSelect = false

        -- Check if it's an NPC
        if Entity:IsNPC(characterUuid) then
            canSelect = true
        else
            -- Check if it's owned by current user
            local entity = Ext.Entity.Get(characterUuid)
            if entity and entity.UserReservedFor and entity.UserReservedFor.UserID then
                local currentUserEntity = Ext.Entity.Get(USERID)
                if currentUserEntity and currentUserEntity.UserReservedFor and currentUserEntity.UserReservedFor.UserID then
                    canSelect = (entity.UserReservedFor.UserID == currentUserEntity.UserReservedFor.UserID)
                end
            end
        end

        if not canSelect then
            Debug.Print("[BG3SX] Attempted to select character not owned by current user and not an NPC")
            return
        end
    end

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
            charOrNPC.CharacterButton.Tint = {0.0, 0.9, 0.0, 1.0} -- Green Selected Color
            charOrNPC.Selected = true
            self.SelectedCharacter = charOrNPC
        else
            charOrNPC.CharacterButton.Tint = {1.0, 1.0, 1.0, 1.0} -- Reset to regular
            charOrNPC.Selected = false
        end
    end

    Event.RequestWhitelistStatus:SendToServer({ID = USERID, Uuid = characterUuid})
end

-- Event.SetSelectedCharacter:SetHandler(function (payload)
    -- Empty Handler currently to avoid console prints
    -- Todo: Do something with it
    -- local x = payload
-- end)

-- Only one can be hovered at a time

---@class PartyInterface
---@field GetHovered fun(self:PartyInterface):CharacterInterface|NPCInterface|nil
function PartyInterface:GetHovered()
    -- _P("GetHovered called")
    -- Debug.DumpS(self)
    if self.Characters then
        -- _P("1")
        for _,character in pairs(self.Characters) do
            -- _P("2")
            -- _D(character.CharacterButton.StatusFlags)
            if character.CharacterButton.StatusFlags["HoveredRect"] then
                -- _P("3")
                return character
            end
        end
    end
    if self.CurrentNPCs then
        for _,npc in pairs(self.CurrentNPCs) do
            if npc.CharacterButton.StatusFlags["HoveredRect"] then
                return npc
            end
        end
    end
    return nil
end

function PartyInterface:AddSelectedNPCSection()

end



return PartyInterface
