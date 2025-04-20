NPCTab = {}
NPCTab.__index = NPCTab




----------------------------------------------------------------------------------------------------
-- 
-- 								    	Other
-- 
----------------------------------------------------------------------------------------------------



local function IsNPC(entity)
    local E = Helper.GetPropertyOrDefault(entity,"CharacterCreationStats", nil)
    if E then
        return false
    else
        return true
    end
end


function NPCTab:RequestStripNPC()

        local uuid = UIInstance.GetSelectedCharacter()
        --print("dumping options")
        --_D(self.InRange.Choice.Options)
        -- print("got ", uuid)

        if not uuid then

            local text = "            No NPC selected. Please select one first before clicking \"Strip\""
            UIHelper.AddTemporaryTooltip(self.StripButton, 2000, text)
            return
        end

        Event.RequestStripNPC:SendToServer({uuid = uuid})
        Event.RequestGiveGenitalsNPC:SendToServer({uuid = uuid})

end


function NPCTab:RequestDressNPC()

        local uuid = UIInstance.GetSelectedCharacter()

        if not uuid then
            local text = "            No NPC selected. Please select one first before clicking \"Dress\""
            UIHelper.AddTemporaryTooltip(self.DressButton, 2000, text)
            return
        end

        Event.RequestDressNPC:SendToServer({uuid = uuid})
        Event.RequestRemoveGenitalsNPC:SendToServer({uuid = uuid})
end




function NPCTab:ScanForNPCs()
    local allCharacters = {}
    local allEntities = Ext.Entity.GetAllEntitiesWithComponent("ClientCharacter")

    for _,entity in pairs(allEntities) do
        table.insert(allCharacters, entity.Uuid.EntityUuid)
    end

    Event.FetchWhitelistedNPCs:SendToServer({tbl = allCharacters, client = USERID})
end



Event.SendWhitelistedNPCs:SetHandler(function (payload)
    local whitelisted = payload

    local inRange = {}
    local hostPos = _C().Transform.Transform.Translate
    local distance = UIInstance.NPCTab.InRange.Range.Value[1]
    -- print("scanning distance")
    -- _P(distance)

    for _, character in pairs(whitelisted) do

        local entity = Ext.Entity.Get(character)
        local NPCLocation = entity.Transform.Transform.Translate

        -- to also consider y coordinates ()
        -- maybe someone is hidden in the floor idk
        if  Math.is_within_distance_x_y(_C(), entity, distance)then
            if IsNPC(entity) then
                table.insert(inRange, Helper.GetName(entity.Uuid.EntityUuid) .. " - " .. entity.Uuid.EntityUuid)
            end
        end
    end

    --_D(inRange)

    local choice = UIInstance.NPCTab.InRange.Choice
    choice.Options = inRange

    if choice.SelectedIndex == 0 then
        choice.SelectedIndex = choice.SelectedIndex +1
    end


    choice.OnChange = function()
        -- Debug.Print("OnChange")
        -- _DS(UIInstance.AppearanceTab)

        -- Debug.Print("Chose an NPC")
        -- Debug.Print("Remeber to change the text in genitals tab")

        -- local npc = choice.Options[choice.SelectedIndex + 1]
        -- local text = UIInstance.AppearanceTab.CurrentCharacter
        -- local clear = UIInstance.AppearanceTab.ClearChoiceButton

        -- local uuid = npc:match(" %- (.+)")
        -- UIInstance.PartyInterface:SetSelectedCharacter(uuid)
        -- UIInstance.PartyInterface:UpdateNPCs()

        -- text.Label = "Current Character: " .. npc
        -- text.Visible = true
        -- clear.Visible = true
    end
end)


function UI:NewNPCTab()
    if self.NPCTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem(Ext.Loca.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs")),
    }, NPCTab)
    return instance
end

function NPCTab:Initialize()

    self.Tab:AddText("Select a range to scan for NPCs")

    -- scan once on initializing
    self:ScanForNPCs()

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

    self.AddButton = self.Tab:AddButton("Add")
    self.AddButton.IDContext = math.random(1000,100000)
    self.AddButton.OnClick = function(button,npc)
        print("Add NPC button clicked for ", npc)

        if not npc then
            print("no npc added in function, choosing selected from list")
            npc = self.InRange.Choice.Options[self.InRange.Choice.SelectedIndex + 1]
            print(npc)
        end

        if npc then
            local uuid = npc:match(" %- (.+)")
            print("uuid is ", uuid)
            local PI = UIInstance.PartyInterface
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
end

function NPCTab:UpdateRangeFinder()

end

-- for client to add NPCs to UI
 Event.RestoreNPCTab:SetHandler(function(payload)
    --print("Client received Event: RestoreNPCTab. Dumping npcs")
    -- local npcs = payload.npcs 
    local previouslySelected = UIInstance.GetSelectedCharacter()
    for _,npc in pairs (payload.npcs) do
        UIInstance.NPCTab.AddButton:OnClick(npc)
    end
    UIInstance.PartyInterface:SetSelectedCharacter(previouslySelected)
    UIInstance.AppearanceTab:FetchGenitals()
 end)