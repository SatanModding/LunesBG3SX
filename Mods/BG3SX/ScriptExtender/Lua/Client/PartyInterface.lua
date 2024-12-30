-- TODO - fetch party on client by checking Entitities with component PartyMember (check if it includes summons)


PartyInterface = {}
PartyInterface.__index = PartyInterface
function UI:NewPartyInterface()
    local instance = setmetatable({
        --UI = self.ID,
        Wrapper = self.Window:AddCollapsingHeader("Party"),
        Party = {}
    }, PartyInterface)
    return instance
end


function PartyInterface:Initialize()
    local userUUID = _C().Uuid.EntityUuid
    --UIEvents.FetchParty:SendToServer({ID = USERID})
    UIEvents.FetchParty:SendToServer(userUUID)
end

function PartyInterface:UpdateParty()
    UI.DestroyChildren(self.Wrapper)
    local tWidth = 4
    local t = self.Wrapper:AddTable("",tWidth)
    local row = t:AddRow()
    local characterCount = 0
    for i, uuid in ipairs(self.Party) do
        if i % tWidth == 0 then
            row = t:AddRow()
        end
        PartyInterface:AddCharacter()
    end
end

function PartyInterface:AddCharacter()

end