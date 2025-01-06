--Event Creation
function UIEvents:Initialize()
    -- Party
        -- Client -> Server
    self.FetchParty = Ext.Net.CreateChannel(ModuleUUID, "FetchParty")
        -- Server -> Client
    self.SendParty = Ext.Net.CreateChannel(ModuleUUID, "SendParty")

    -- General
        -- Client -> Server
    self.ChangeCharacter = Ext.Net.CreateChannel(ModuleUUID, "ChangeCharacter")
    self.FetchScenes = Ext.Net.CreateChannel(ModuleUUID, "FetchScenes")
        -- Server -> Client
    self.SendScenes = Ext.Net.CreateChannel(ModuleUUID, "SendScenes")
    self.UpdateScenes = Ext.Net.CreateChannel(ModuleUUID, "UpdateScenes")

    -- Scene specific
        -- Client -> Server
    self.AskForSex = Ext.Net.CreateChannel(ModuleUUID, "AskForSex")
    self.ChangeAnimation = Ext.Net.CreateChannel(ModuleUUID, "ChangeAnimation")
    self.SwapPosition = Ext.Net.CreateChannel(ModuleUUID, "SwapPosition")
    self.RotateScene = Ext.Net.CreateChannel(ModuleUUID, "RotateScene")
    self.ChangeCameraHeight = Ext.Net.CreateChannel(ModuleUUID, "ChangeCameraHeight")
    self.MoveScene = Ext.Net.CreateChannel(ModuleUUID, "MoveScene")
    self.StopSex = Ext.Net.CreateChannel(ModuleUUID, "StopSex")
        -- Server -> Client
    self.NewScene = Ext.Net.CreateChannel(ModuleUUID, "NewScene")

    -- Genitals
        -- Client -> Server
    self.FetchGenitals = Ext.Net.CreateChannel(ModuleUUID, "FetchGenitals")
    self.SetActiveGenital = Ext.Net.CreateChannel(ModuleUUID, "SetActiveGenital")
    self.SetInactiveGenital = Ext.Net.CreateChannel(ModuleUUID, "SetInactiveGenital")
        -- Server -> Client
    self.SendGenitals = Ext.Net.CreateChannel(ModuleUUID, "SendGenitals")

    -- Settings
        -- Client -> Server
    self.FetchAnimations = Ext.Net.CreateChannel(ModuleUUID, "FetchAnimations")
    self.FetchAllAnimations = Ext.Net.CreateChannel(ModuleUUID, "FetchAllAnimations")
    self.FetchFilteredAnimations = Ext.Net.CreateChannel(ModuleUUID, "FetchFilteredAnimations")
    --self.AutoErectionsOn = Ext.Net.CreateChannel(ModuleUUID, "AutoErectionsOn")
    --self.AutoErectionsOff = Ext.Net.CreateChannel(ModuleUUID, "AutoErectionsOff")
        -- Server -> Client
    self.SendAllAnimations = Ext.Net.CreateChannel(ModuleUUID, "SendAllAnimations")
    self.SendFilteredAnimations = Ext.Net.CreateChannel(ModuleUUID, "SendFilteredAnimations")

    --self.SendAnimations = Ext.Net.CreateChannel(ModuleUUID, "SendAnimations")


    self.CustomEvent = Ext.Net.CreateChannel(ModuleUUID, "CustomEvent")

    self.RequestTeleport = Ext.Net.CreateChannel(ModuleUUID, "RequestTeleport")
    self.RequestRotation = Ext.Net.CreateChannel(ModuleUUID, "RequestRotation")

    -- Whitelist Tab
        -- Client -> Server
    self.FetchWhitelist = Ext.Net.CreateChannel(ModuleUUID, "FetchWhitelist")
        -- Server -> Client
    self.SendWhitelist = Ext.Net.CreateChannel(ModuleUUID, "SendWhitelist")



    self.RequestStripNPC = Ext.Net.CreateChannel(ModuleUUID, "RequestStripNPC")
    self.RequestDressNPC = Ext.Net.CreateChannel(ModuleUUID, "RequestDressNPC")

end

UIEvents:Initialize()


-- example usaCge

-- Client -> Server
-- UIEvents.FetchAllAnimations:SendToServer({ID = UI.ID})
-- UIEvents.SwapPosition:SendToServer({ID = UI.ID, Scene = scene, Position = pos})
--     -- Do something on Server
--     SwapPosition(payload.Scene, payload.Position)


-- -- Server -> Client
-- local allAnimations = {}
-- UIEvents.SendAllAnimations:SendToClient(allAnimations, payload.ID)