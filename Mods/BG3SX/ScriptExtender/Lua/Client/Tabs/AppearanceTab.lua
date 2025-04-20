local function IsNPC(entity)
    local E = Helper.GetPropertyOrDefault(entity,"CharacterCreationStats", nil)
    if E then
        return false
    else
        return true
    end
end


AppearanceTab = {}
AppearanceTab.__index = AppearanceTab
function UI:NewAppearanceTab()
    if self.AppearanceTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem(Ext.Loca.GetTranslatedString("h36809485096e467682a34b1a780bb4a4a816", "Appearance")),
        GenitalsLoaded = nil,
        Genitals = {},
    }, AppearanceTab)
    return instance
end


function AppearanceTab:UpdateStrippingGroup(uuid)

    UI.DestroyChildren(self.StrippingArea)

    local entity = Ext.Entity.Get(uuid)
    local stripping = SexUserVars.GetAllowStripping(entity)

    local allowStripBox = self.StrippingArea:AddCheckbox(Ext.Loca.GetTranslatedString("hd050a087bef04ed4b4b8c775b458b6c2d786", "Allow Stripping"))
    
    if (stripping == false) then

        allowStripBox.Checked = false
    else
        allowStripBox.Checked = true
    end

    allowStripBox.OnChange = function()
        if allowStripBox.Checked == true then
            SexUserVars.SetAllowStripping(true, entity)
        else
            SexUserVars.SetAllowStripping(false, entity)
        end
    end
end

function AppearanceTab:UpdateToggleVisibilityGroup(uuid)
    UI.DestroyChildren(self.ToggleVisibilityArea)

    local entity = Ext.Entity.Get(uuid)
    local isInvis = SexUserVars.IsInvisible(entity)

    self.IsInvisBox = self.ToggleVisibilityArea:AddCheckbox(Ext.Loca.GetTranslatedString("h2080108a2c8d4e509be9b53c2421a1c4eb95", "Toggle Invisibility"))
    
    if (self.IsInvisBox == false) then

        self.IsInvisBox.Checked = false
    else
        self.IsInvisBox.Checked = true
    end

    self.IsInvisBox.OnChange = function()
        if self.IsInvisBox.Checked == true then
            self.IsInvisBox.Checked = false
            Event.ToggleInvisibility:SendToServer({Uuid = uuid, Value = true})
        else
            self.IsInvisBox.Checked = true
            Event.ToggleInvisibility:SendToServer({Uuid = uuid, Value = false})
        end
    end
end

Event.SetInvisible:SetHandler(function (payload)
    if UIInstance:GetSelectedCharacter() == payload.Uuid then
        UIInstance.AppearanceTab.IsInvisBox.Checked = payload.Value
    end
end)


function AppearanceTab:UpdateEquipmentAreaGroup(uuid)

    UI.DestroyChildren(self.EquipmentArea)
    -- TODO- add the Strip and redress buttons when an NPC is selected ONLY

    local entity = Ext.Entity.Get(uuid)

    if not entity then
        Debug.Print("Is not entity " .. uuid)
        return
    end

    if IsNPC(entity) then
        local npcTab = UIInstance.NPCTab
        self.StripButton = self.EquipmentArea:AddButton(Ext.Loca.GetTranslatedString("h5217dc9e84404c68a890c1b21fb1b22dca33", "Strip NPC"))

        self.StripButton.OnClick = function()
            -- print("Strip NPC button clicked")
            npcTab:RequestStripNPC()
        end


        self.DressButton = self.EquipmentArea:AddButton(Ext.Loca.GetTranslatedString("h95893257756e4bacba737e735eb75c6ba1d0", "Dress NPC"))
        self.DressButton.SameLine = true

        self.DressButton.OnClick = function()
            -- print("Dress NPC button clicked")
            npcTab:RequestDressNPC()
        end

    end
    
end

function AppearanceTab:Initialize()
    -- self.Tab:AddSeparatorText("Stripping:") -- Seems to take up too much space with stripping being just a single checkbox
    if not self.StrippingArea then
        self.StrippingArea = self.Tab:AddGroup("")
    end

    -- if not self.ToggleVisibilityArea then
    --     self.ToggleVisibilityArea = self.Tab:AddGroup("")
    --     self.ToggleVisibilityArea.SameLine = true
    -- end

    -- self.Tab:AddSeparatorText("Equipment:")
    if not self.EquipmentArea then
        self.EquipmentArea = self.Tab:AddGroup("")
    end

    local sep = self.Tab:AddSeparatorText(Ext.Loca.GetTranslatedString("hfe5bebe645244c108b0fd82dcf10dcc22177", "Genitals"))
    sep:SetStyle("SeparatorTextPadding", 5)
    if not self.GenitalArea then
        self.GenitalArea = self.Tab:AddGroup("")
    end
end


function AppearanceTab:FetchGenitals()
    -- self.AwaitingGenitals = true
    Event.FetchGenitals:SendToServer({ID = USERID, Character = UIInstance.GetSelectedCharacter() or _C().Uuid.EntityUuid})
end

function AppearanceTab:UpdateGenitalGroup(whitelisted)
    UI.DestroyChildren(self.GenitalArea)
    local buttonID = 0
    if whitelisted then
        for Category,Genitals in pairsByKeys(self.Genitals) do
            local categoryHeader = self.GenitalArea:AddCollapsingHeader(Category)

            -- Rename payload to regular names - TODO: Fix Payload
            if Category == "BG3SX_VanillaVulva" then
                categoryHeader.Label = Ext.Loca.GetTranslatedString("h12336834b5e64857bed909e165f752393cfb", "Vanilla Vulvas")
            elseif Category == "BG3SX_VanillaFlaccid" then
                categoryHeader.Label = Ext.Loca.GetTranslatedString("hd0e090c89d924fa8ba6bfa2000ff8f479d8a", "Vanilla Penises")
            elseif Category == "BG3SX_SimpleErections" then
                categoryHeader.Label = Ext.Loca.GetTranslatedString("ha0ba5dd9dcc94acca77258ba6254decb3784", "MrFunsize Erections")
            elseif Category == "BG3SX_OtherGenitals" then
                categoryHeader.Label = Ext.Loca.GetTranslatedString("h7d29c52c0c6a4e7d8e2d284f0267b139f1ec", "Modded Genitals")
            end

            local genitalTable = categoryHeader:AddTable("",3)
            local currentRow = genitalTable:AddRow()
            for i,Genital in ipairs(Genitals) do
                if i % 3 == 0 then
                    currentRow = genitalTable:AddRow()
                end
                local cell = currentRow:AddCell()
                local popup = cell:AddPopup("GenitalChoice")
                local genitalSelectable = cell:AddSelectable(Genital.name)
                -- local genitalButton = categoryHeader:AddButton(Genital.name)
                genitalSelectable.OnClick = function()
                    genitalSelectable.Selected = false
                    popup:Open()
                end
                local inactiveGenital = popup:AddSelectable("Out of Sex")
                local activeGenital = popup:AddSelectable("During Sex")

                -- local inactiveGenitalButton = categoryHeader:AddButton("Out of Sex")
                -- local activeGenitalButton = categoryHeader:AddButton("During Sex")
                -- local genitalChoice = categoryHeader:AddText(Genital.name)
                -- genitalChoice.SameLine = true
                -- activeGenitalButton.SameLine = true

                if Genital.name == "" then
                    genitalSelectable.Label = "No Name"
                    -- genitalChoice.Label = "No Name"
                end

                buttonID = buttonID + 1
                activeGenital.IDContext = buttonID
                buttonID = buttonID + 1
                inactiveGenital.IDContext = buttonID

                activeGenital.OnClick = function()
                    activeGenital.Selected = false
                    local uuid = UIInstance.GetSelectedCharacter()
                    -- print("current character accordin to the label is ", uuid)
                    Event.SetActiveGenital:SendToServer({ID = USERID, Genital = Genital.uuid, uuid = UIInstance.GetSelectedCharacter()})
                end
                inactiveGenital.OnClick = function()
                    activeGenital.Selected = false
                    local uuid = UIInstance.GetSelectedCharacter()
                    -- print("current character accordin to the label is ", uuid)
                    Event.SetInactiveGenital:SendToServer({ID = USERID, Genital = Genital.uuid, uuid = UIInstance.GetSelectedCharacter()})
                end
            end
        end
    end
end



-- Check for NULL REFERENCEs because of too early destroyed IMGUI elements
-- for i = 1000, 5000 do
--     Ext.Timer.WaitFor(i, function()
--         if UIInstance.AppearanceTab then
--             if UIInstance.AppearanceTab.Tab then
--                 print("Dumping AppearanceTab state...")
--                 for k, v in pairs(UIInstance.AppearanceTab) do
--                     print(k, v)
--                 end
--             else
--                 print("AppearanceTab.Tab is invalid or was destroyed!")
--             end
--         else
--             print("AppearanceTab object no longer exists!")
--         end
--     end)
-- end