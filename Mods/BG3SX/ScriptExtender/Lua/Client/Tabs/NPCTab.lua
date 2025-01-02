NPCTab = {}
NPCTab.__index = NPCTab

function UI:NewNPCTab()
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("NPCs"),
    }, NPCTab)
    return instance
end

function NPCTab:Initialize()
    self.Tab:AddText("Select a range an NPC to ")
    self.InRange = {}
    local r = self.InRange
    r.Range = self.Tab:AddSliderInt("")
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

    r.Select = self.Tab:AddButton("Select")
    r.Select.SameLine = true
    r.Select.OnClick = function()
        
        r.Select.Visible = false
    end
end

function NPCTab:UpdateRangeFinder()

end