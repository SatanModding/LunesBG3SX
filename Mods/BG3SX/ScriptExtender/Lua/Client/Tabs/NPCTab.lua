---@class NPCTab
---@field Tab ExtuiTabItem
---@field InRange table
---@field AddButton ExtuiButton
---@field StripButton ExtuiButton
---@field DressButton ExtuiButton
NPCTab = {}
NPCTab.__index = NPCTab

local allNPCs = {}
local allWhiteListedNPCs = {}

----------------------------------------------------------------------------------------------------
--
-- 								    	Other
--
----------------------------------------------------------------------------------------------------

function NPCTab:RequestStripNPC()
    local uuid = UI:GetSelectedCharacter()
    --print("dumping options")
    --_D(self.InRange.Choice.Options)
    -- print("got ", uuid)

    if not uuid then
        local text = "            " .. Locale.GetTranslatedString("haac4a3c8852044d39fbfc2ab012eaeb7f906", "No NPC selected. Please select one first before clicking" .. " " .. Locale.GetTranslatedString("hbc4d2b25fabe48a2a97d814eac21ce6ed487", "\"Strip\""))
        UIHelper.AddTemporaryTooltip(self.StripButton, 2000, text)
        return
    end

    Event.RequestStripNPC:SendToServer({uuid = uuid})
    Event.RequestGiveGenitalsNPC:SendToServer({uuid = uuid})
end

function NPCTab:RequestDressNPC()

        local uuid = UI:GetSelectedCharacter()

        if not uuid then
            local text = "            " .. Locale.GetTranslatedString("haac4a3c8852044d39fbfc2ab012eaeb7f906", "No NPC selected. Please select one first before clicking" .. " " .. Locale.GetTranslatedString("h19e30b9a3be84c7bb57c0cc8b894fe0d84ff", "\"Dress\""))
            UIHelper.AddTemporaryTooltip(self.DressButton, 2000, text)
            return
        end

        Event.RequestDressNPC:SendToServer({uuid = uuid})
        Event.RequestRemoveGenitalsNPC:SendToServer({uuid = uuid})
end

function NPCTab.FetchAllNPCs()
    -- print("Fethcing all NPCs")
    local allEntities = Ext.Entity.GetAllEntitiesWithComponent("ClientCharacter")

    for _,entity in pairs(allEntities) do
        table.insert(allNPCs, entity.Uuid.EntityUuid)
    end

    -- print("fetched all NPCs")

    -- print("sending event: FetchWhitelistedNPCs:SendToServer")
    -- print("with userid ", USERID)
    Event.FetchWhitelistedNPCs:SendToServer({tbl = allNPCs, client = USERID})
end

Event.SendWhitelistedNPCs:SetHandler(function (payload)
    -- print("assigned whitelistedNPCs")
    allWhiteListedNPCs = payload
end)

function NPCTab:ScanForNPCs()
    if UI.Ready then
        --print("Scanning for NPCs")
        local inRange = {}
        -- local hostPos = _C().Transform.Transform.Translate
        local distance = UI.NPCTab.InRange.Range.Value[1]
        --print("In distance ", distance)

        for _, character in pairs(allWhiteListedNPCs) do
            local entity = Ext.Entity.Get(character)
            if entity and Math.IsWithinDistanceBetweenEntities(_C(), entity, distance) then
                if IsNPC(entity) then
                    table.insert(inRange, Helper.GetName(entity.Uuid.EntityUuid) .. " - " .. entity.Uuid.EntityUuid)
                end
            end
        end

        --_D(inRange)

        -- local choice = UI.NPCTab.InRange.Choice
        -- choice.Options = inRange

        -- if choice.SelectedIndex == 0 then
        --     choice.SelectedIndex = choice.SelectedIndex +1
        -- end

        local choice = UI.NPCTab.InRange.Choice
        choice.Options = inRange

        if choice.Options and #choice.Options > 0 then
            choice.SelectedIndex = 0
        end
        choice.OnChange = function()
            -- Debug.Print("OnChange")
            -- _DS(UI.AppearanceTab)

            -- Debug.Print("Chose an NPC")
            -- Debug.Print("Remeber to change the text in genitals tab")

            -- local npc = choice.Options[choice.SelectedIndex + 1]
            -- local text = UI.AppearanceTab.CurrentCharacter
            -- local clear = UI.AppearanceTab.ClearChoiceButton

            -- local uuid = npc:match(" %- (.+)")
            -- UI.PartyInterface:SetSelectedCharacter(uuid)
            -- UI.PartyInterface:UpdateNPCs()

            -- text.Label = "Current Character: " .. npc
            -- text.Visible = true
            -- clear.Visible = true
        end
    end
end

---@param holder ExtuiTabBar
function NPCTab:New(holder)
    if UI.NPCTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        Tab = holder:AddTabItem(Locale.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs")),
    }, NPCTab)
    return instance
end

function NPCTab:Init()

    self.Tab:AddText(Locale.GetTranslatedString("h59abcbc0950c48a8856f7bf76b8954a95c30", "Select a range to scan for NPCs"))
    self.Tab:AddText(Locale.GetTranslatedString("h4d9b00350d494c55ba5b35ccdd087da5b7eg", "You can also start a scene by selecting the NPC in the game world"))

    -- print("initializing InRange")

    self.InRange = {}
    local r = self.InRange
    r.Range = self.Tab:AddSliderInt("", 5,1,10)

    r.NPCs = {}
    r.Select = nil
    r.Choice = self.Tab:AddCombo("")
    r.Choice.Options = r.NPCs
    r.Choice.SelectedIndex = 1

    r.Range.OnChange = function()
        if r.Choice.SelectedIndex ~= 0 then
            self:ScanForNPCs()
        end
    end

    self.AddButton = self.Tab:AddButton(Locale.GetTranslatedString("ha3f7c0a527914bf4bc0b48deb907abd4d9b4", "Add"))
    self.AddButton.IDContext = tostring(math.random(1000,100000))
    self.AddButton.OnClick = function(button,npc)
        -- print("Add NPC button clicked for ", npc)

        if not npc then
            -- print("no npc added in function, choosing selected from list")
            npc = self.InRange.Choice.Options[self.InRange.Choice.SelectedIndex + 1]
            -- print(npc)
        end
        if npc then
            local uuid = npc:match(" %- (.+)")
            -- print("uuid is ", uuid)
            local PI = UI.PartyInterface
            if PI then
                if not Table.Contains(PI.NPCs, uuid) then
                    table.insert(PI.NPCs, uuid)
                    PI:UpdateNPCs()
                    Event.AddedNPCToTab:SendToServer({ID=USERID, npc = npc})
                else
                    Debug.Print("This NPC has already been added!")
                    -- UIHelper.AddTemporaryTooltip(self.AddButton, 2000, "This NPC has already been added!")
                end
            end
        end
    end
    -- scan once after initializing
    -- print("SETTING UIEXIST TO TRUE")


    self.ManualScan = self.Tab:AddButton(Locale.GetTranslatedString("ha855f8e5f75646058d05bdcf3ba8b67443d2", "Scan"))
    self.ManualScan.IDContext = tostring(math.random(1000,100000))
    self.ManualScan.SameLine = true
    self.ManualScan.Visible = true
    self.ManualScan.OnClick = function()
        self:ScanForNPCs()
    end

    self:ScanForNPCs()
end

function NPCTab:UpdateRangeFinder()

end

-- for client to add NPCs to UI
Event.RestoreNPCTab:SetHandler(function(payload)
    local function condition()
        return UI.Ready == true and UI.PartyInterface.SelectedCharacter ~= nil
    end

    local function restoreNPCTab()
        --print("Client received Event: RestoreNPCTab. Dumping npcs")
        -- local npcs = payload.npcs
        local previouslySelected = UI:GetSelectedCharacter()
        for _,npc in pairs (payload.npcs) do
            UI.NPCTab.AddButton:OnClick(npc)
        end
        UI.PartyInterface:SetSelectedCharacter(previouslySelected)
        UI.AppearanceTab:FetchGenitals()
        -- UI.AppearanceTab:UpdateReplicationListener() -- this wasn't enabled, only enable the other commented out ones, check if this is needed
    end

    Helper.DelayUntilTrue(restoreNPCTab, condition, 100)
end)

 -- payload is irrelevant. I just added it in case it throws an error otherwise
-- Event.SessionLoaded:SetHandler(function (payload)
--     print("Session Loaded Event Received on Client")
--     local x = payload
--     NPCTab.FetchAllNPCs()
-- end)

local tick = 0
-- TODO - create settings

local function OnTick()
    tick = tick +1
    -- all 6 seconds assuming 60 ticks / second
    local TASK_CHECK_FREQUENCY = 360

    if (tick % TASK_CHECK_FREQUENCY == 0) then
        if UI.Ready and UI.Settings.NPCTab.AutomaticScan.Checked then
            NPCTab:ScanForNPCs()
        end
    end
end

Ext.Events.Tick:Subscribe(OnTick)

return NPCTab
