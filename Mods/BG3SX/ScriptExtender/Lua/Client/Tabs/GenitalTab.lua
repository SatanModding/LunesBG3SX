GenitalsTab = {}
GenitalsTab.__index = GenitalsTab
function UI:NewGenitalsTab()
    if self.GenitalsTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Genitals"),
        Genitals = {},
    }, GenitalsTab)
    return instance
end

function GenitalsTab:Initialize()
    self.CurrentCharacter = self.Tab:AddText("Current Character: NAN")
    self.CurrentCharacter.Visible = false

    self.ClearChoiceButton = self.Tab:AddButton("Clear Choice")

    self.ClearChoiceButton.OnClick = function()
        Debug.Print("Clearing choice and resetitng to host character")
        self.CurrentCharacter.Label = Helper.GetName(_C().Uuid.EntityUuid .. " - " .. _C().Uuid.EntityUuid)
    end

    self:FetchGenitals()
end

function GenitalsTab:FetchGenitals()
    self.AwaitingGenitals = true
    UIEvents.FetchGenitals:SendToServer({ID = USERID, Character = _C().Uuid.EntityUuid})
end

function GenitalsTab:UpdateGenitalTable()
    UI.DestroyChildren(self.Tab)
    local buttonID = 0
    for Category,Genitals in pairs(self.Genitals) do
        local categoryHeader = self.Tab:AddCollapsingHeader(Category)
        for i,Genital in ipairs(Genitals) do
            if (not Genital.name) or (Genital.name == "") then
                return
            end
            local genitalChoice = categoryHeader:AddText(Genital.name)
            local activeGenitalButton = categoryHeader:AddButton("During Sex")
            local inactiveGenitalButton = categoryHeader:AddButton("Out of Sex")
            activeGenitalButton.SameLine = true
            inactiveGenitalButton.SameLine = true
            buttonID = buttonID + 1
            activeGenitalButton.IDContext = buttonID
            buttonID = buttonID + 1
            inactiveGenitalButton.IDContext = buttonID
            activeGenitalButton.OnClick = function()
                local uuid = self.CurrentCharacter.Label:match(" %- (.+)")
                UIEvents.SetActiveGenital:SendToServer({ID = USERID, Genital = Genital.uuid, uuid = _C().Uuid.EntityUuid})
            end
            inactiveGenitalButton.OnClick = function()
                local uuid = self.CurrentCharacter.Label:match(" %- (.+)") 
                UIEvents.SetInactiveGenital:SendToServer({ID = USERID, Genital = Genital.uuid, uuid = _C().Uuid.EntityUuid})
            end
        end
    end
end


UIEvents.ChangeCharacter:SetHandler(function (payload)
    Debug.Print("Change character recognized. Changing genital tab text")
    Debug.Print("But only if no NPC is selected")

    local npcChoice = UIInstance.NPCTab.InRange.Choice
    local selectedNPC = npcChoice.Options[npcChoice.SelectedIndex + 1]

    if selectedNPC then
        Debug.Print("An NPC is selected, not chaning the text")
        return
    end

    local uuid = payload
    local text = UIInstance.GenitalsTab.CurrentCharacter.Label

    text = "Current Character: " .. Helper.GetName(uuid) .. " - " .. uuid
    text.Visible = true

end)



for i=1000,5000 do
    Ext.Timer.WaitFor(i, function()
        print("dumping genitals")
        _DS(UIInstance.GenitalsTab)
    end)

end