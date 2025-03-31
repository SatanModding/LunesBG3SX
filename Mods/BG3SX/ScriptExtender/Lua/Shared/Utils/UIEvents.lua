---Event Creation
---@param name string
function UIEvents:New(name)
    self[name] = Ext.Net.CreateChannel(ModuleUUID, name)
end

UIEvents:New("CustomEvent")

--- Party
-- Client -> Server
UIEvents:New("SetSelectedCharacter")
UIEvents:New("FetchParty")
-- Server -> Client
UIEvents:New("SendParty")

--- General
-- Client -> Server
UIEvents:New("ChangeCharacter")
UIEvents:New("FetchScenes")
UIEvents:New("SendScenes")
-- Server -> Client
UIEvents:New("UpdateScenes")
UIEvents:New("SetSelectedCharacter")

--- Scene specific
-- Client -> Server
UIEvents:New("AskForSex")
UIEvents:New("ChangeAnimation")
UIEvents:New("SwapPosition")
UIEvents:New("RotateScene")
UIEvents:New("ChangeCameraHeight")
UIEvents:New("MoveScene")
UIEvents:New("StopSex")
UIEvents:New("RequestTeleport")
UIEvents:New("RequestRotation")
UIEvents:New("TogglePause")
-- Server -> Client
UIEvents:New("NewScene")
UIEvents:New("DestroyAllSceneControls")

--- Genitals
UIEvents:New("GenitalsLoaded")
-- Client -> Server
UIEvents:New("FetchGenitals")
UIEvents:New("SetActiveGenital")
UIEvents:New("SetInactiveGenital")
UIEvents:New("SetupInvisUserVars")
UIEvents:New("ToggleInvisibility")
UIEvents:New("SetInvisible")
-- Server -> Client
UIEvents:New("SendGenitals")

--- Settings
-- Client -> Server
UIEvents:New("FetchAnimations")
UIEvents:New("FetchAllAnimations")
UIEvents:New("FetchFilteredAnimations")
-- UIEvents:New("AutoErectionsOn")
-- UIEvents:New("AutoErectionsOff")
-- Server -> Client
UIEvents:New("SendAllAnimations")
UIEvents:New("SendFilteredAnimations")

-- UIEvents:New("SendAnimations")

--- Whitelist Tab
-- Client -> Server
UIEvents:New("FetchUserTags")
UIEvents:New("FetchWhitelist")
-- Server -> Client
UIEvents:New("SendUserTags")
UIEvents:New("SendWhitelist")

--- Whitelist Tab
-- Client -> Server
UIEvents:New("RequestStripNPC")
UIEvents:New("RequestDressNPC")
UIEvents:New("RequestGiveGenitalsNPC")
UIEvents:New("RequestRemoveGenitalsNPC")
UIEvents:New("FetchWhitelistedNPCs")
--  Server -> Client
UIEvents:New("SendWhitelistedNPCs")
UIEvents:New("SendNPCStrip")
UIEvents:New("SendNPCDress")

--- NPCSync

-- Server -> Client


-- example usaCge

-- Client -> Server
-- UIEvents.FetchAllAnimations:SendToServer({ID = UI.ID})
-- UIEvents.SwapPosition:SendToServer({ID = UI.ID, Scene = scene, Position = pos})
--     -- Do something on Server
--     SwapPosition(payload.Scene, payload.Position)


-- -- Server -> Client
-- local allAnimations = {}
-- UIEvents.SendAllAnimations:SendToClient(allAnimations, payload.ID)