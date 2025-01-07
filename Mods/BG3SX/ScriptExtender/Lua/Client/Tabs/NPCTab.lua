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
        local npc = self.InRange.Choice.Options[self.InRange.Choice.SelectedIndex + 1]
        local uuid = npc:match(" %- (.+)")
        print("dumping options")
        _D(self.InRange.Choice.Options)
        print("got ", uuid)

        if not npc then
            local text = "            No NPC selected. Please select one first before clicking \"Strip\""
            UIHelper.AddTemporaryTooltip(self.StripButton, 2000, text)
            return
        end

        UIEvents.RequestStripNPC:SendToServer({uuid = npc})
        UIEvents.RequestGiveGenitalsNPC:SendToServer({uuid = npc})

end


function NPCTab:RequestDressNPC()

        local npc = self.InRange.Choice.Options[self.InRange.Choice.SelectedIndex + 1]

        if not npc then
            local text = "            No NPC selected. Please select one first before clicking \"Dress\""
            UIHelper.AddTemporaryTooltip(self.DressButton, 2000, text)
            return
        end

        UIEvents.RequestDressNPC:SendToServer({uuid = npc})
        UIEvents.RequestRemoveGenitalsNPC:SendToServer({uuid = npc})
end




function NPCTab:ScanForNPCs()
    local allCharacters = {}
    local allEntities = Ext.Entity.GetAllEntitiesWithComponent("ClientCharacter")

    for _,entity in pairs(allEntities) do
        table.insert(allCharacters, entity.Uuid.EntityUuid)
    end

    UIEvents.FetchWhitelistedNPCs:SendToServer({tbl = allCharacters, client = _C().Uuid.EntityUuid}) 
end



UIEvents.SendWhitelistedNPCs:SetHandler(function (payload)
    local whitelisted = payload

    local inRange = {}
    local hostPos = _C().Transform.Transform.Translate
    local distance = UIInstance.NPCTab.InRange.Range.Value[1]
    print("scanning distance")
    _P(distance)

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

    _D(inRange)

    local choice = UIInstance.NPCTab.InRange.Choice
    choice.Options = inRange

    if choice.SelectedIndex == 0 then
        choice.SelectedIndex = choice.SelectedIndex +1
    end


    choice.OnChange = function()

        Debug.Print("OnChange")
        _DS(UIInstance.GenitalsTab)

        Debug.Print("Chose an NPC")
        Debug.Print("Remeber to change the text in genitals tab")

        local npc = choice.Options[choice.SelectedIndex + 1]
        local text = UIInstance.GenitalsTab.CurrentCharacter.Label

        text = "Current Character: " .. npc
        text.Visible = true

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

    self.ScanButton = self.Tab:AddButton("Scan")
    self.ScanButton:Tooltip():AddText("Scan Area for NPCs")

    self.InRange = {}
    local r = self.InRange
    r.Range = self.Tab:AddSliderInt("", 5,1,10)
    r.NPCs = {}
    r.Select = nil
    r.Choice = self.Tab:AddCombo("")
    r.Choice.Options = r.NPCs
    r.Choice.SelectedIndex = 1
    r.Choice.OnChange = function()
        if r.Choice.SelectedIndex ~= 0 then
            
            r.Select.Visible = true
        end
    end

    --r.Select = self.Tab:AddButton("Select")
    --r.Select.SameLine = true
    --r.Select.OnClick = function()
        
       -- r.Select.Visible = false
    --end

    
    self.StripButton = self.Tab:AddButton("Strip NPC")

    self.StripButton.OnClick = function()
        print("Strip NPC button clicked")
        self:RequestStripNPC()
    end


    self.DressButton = self.Tab:AddButton("Dress NPC")
    self.DressButton.SameLine = true

    self.DressButton.OnClick = function()
        print("Dress NPC button clicked")
        self:RequestDressNPC()
    end

    self.ScanButton.OnClick = function()
        self:ScanForNPCs()
    end

end

function NPCTab:UpdateRangeFinder()

end