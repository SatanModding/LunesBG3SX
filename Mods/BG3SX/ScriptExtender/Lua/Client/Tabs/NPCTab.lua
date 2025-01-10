NPCTab = {}
NPCTab.__index = NPCTab

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
        print("got ", uuid)

        if not uuid then
            
            local text = "            No NPC selected. Please select one first before clicking \"Strip\""
            UIHelper.AddTemporaryTooltip(self.StripButton, 2000, text)
            return
        end

        UIEvents.RequestStripNPC:SendToServer({uuid = uuid})
        UIEvents.RequestGiveGenitalsNPC:SendToServer({uuid = uuid})

end


function NPCTab:RequestDressNPC()

        local uuid = UIInstance.GetSelectedCharacter()

        if not uuid then
            local text = "            No NPC selected. Please select one first before clicking \"Dress\""
            UIHelper.AddTemporaryTooltip(self.DressButton, 2000, text)
            return
        end

        UIEvents.RequestDressNPC:SendToServer({uuid = uuid})
        UIEvents.RequestRemoveGenitalsNPC:SendToServer({uuid = uuid})
end




function NPCTab:ScanForNPCs()
    local allCharacters = {}
    local allEntities = Ext.Entity.GetAllEntitiesWithComponent("ClientCharacter")

    for _,entity in pairs(allEntities) do
        table.insert(allCharacters, entity.Uuid.EntityUuid)
    end

    UIEvents.FetchWhitelistedNPCs:SendToServer({tbl = allCharacters, client = USERID}) 
end



UIEvents.SendWhitelistedNPCs:SetHandler(function (payload)
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
        Tab = self.TabBar:AddTabItem("NPCs"),
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
    self.AddButton.OnClick = function()
        print("Add NPC button clicked")

        local npc = self.InRange.Choice.Options[self.InRange.Choice.SelectedIndex + 1]

        if npc then
            local uuid = npc:match(" %- (.+)")
            local PI = UIInstance.PartyInterface
            if PI then
                if not Table.Contains(PI.NPCs, uuid) then
                    table.insert(PI.NPCs, uuid)
                    PI:UpdateNPCs()
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