GenitalsTab = {}
GenitalsTab.__index = GenitalsTab
function UI:NewGenitalsTab()
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Genitals"),
        Genitals = {},
    }, GenitalsTab)
    return instance
end

function GenitalsTab:Initialize()
    self:FetchGenitals()
end

function GenitalsTab:FetchGenitals()
    Debug.Print("fetching genitals")
    self.AwaitingGenitals = true
    UIEvents.FetchGenitals:SendToServer({ID = UIInstance.ID, Character = _C().Uuid.EntityUuid})
end

function GenitalsTab:UpdateGenitalTable()
    UI.DestroyChildren(self.Tab)
    local buttonID = 0
    for Category,Genitals in pairs(self.Genitals) do
        local categoryHeader = self.Tab:AddCollapsingHeader(Category)
        for i,Genital in ipairs(Genitals) do
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
                UIEvents.SetActiveGenital:SendToServer({ID = UIInstance.ID, Genital = Genital.uuid, uuid = _C().Uuid.EntityUuid})
            end
            inactiveGenitalButton.OnClick = function()
                UIEvents.SetInactiveGenital:SendToServer({ID = UIInstance.ID, Genital = Genital.uuid, uuid = _C().Uuid.EntityUuid})
            end
        end
    end
end