NULL = "NULL_00000000-0000-0000-0000-000000000000"
BG3AFActive = nil
if Mods.BG3AF ~= nil then
    BG3AFActive = true
else
    BG3AFActive = false
end

------------------------------------
        -- Init Classes --
------------------------------------

Ext.Require("Client/Camera.lua")

Ext.Require("Shared/_constructor.lua")

-- Ext.Require("Shared/_initData.lua")
Ext.Require("Shared/_initUtils.lua")

Ext.Require("Client/UIHelper.lua")
Ext.Require("Client/UI.lua")
Ext.Require("Client/UIEventHandler.lua")

Ext.Require("Shared/Data/Origins.lua")
Ext.Require("Client/GenitalMessages.lua")
Ext.Require("Server/Classes/Sex/NPC.lua")
Ext.Require("Client/NPCSync.lua") -- NPC changes have to be synced on the client
Ext.Require("Shared/Data/AnimationSets.lua")


local settings = {
    Server = true, 
    Client = true, 
    SyncToClient = true, 
    SyncToServer = true,
    SyncOnWrite = true,
    WriteableOnClient = true,
    WriteableOnServer = true
}

Ext.Vars.RegisterModVariable(ModuleUUID, "BG3SX_AddedNPCs", settings)


Ext.Vars.RegisterModVariable(ModuleUUID, "BG3SX_ShowAllAnimations", {
        Server = true, Client = true, SyncToClient = true
})






local function satanTest(self)    

        local entity = _C()

        local currentRotation = entity.Transform.Transform.RotationQuat
        
        --print("current rotation")
        --_D(currentRotation)

        local newRotation = {currentRotation[1], currentRotation[2] + 0.5, currentRotation[3], currentRotation[4]}

        entity.Transform.Transform.RotationQuat = newRotation

        entity.Visual.Visual:SetWorldRotate(newRotation)

        --print("rotation after setting entity")
        local currentRotation = entity.Transform.Transform.RotationQuat
        --_D(currentRotation)

        _C().Steering.TargetRotation =0,628319 -- 180 degrees in radian 


end


-- https://discord.com/channels/1211056047784198186/1211069350157488209/1324459469891047525
-- function _C()
--         -- 4294901760 is the null user ID 
--         local controlled = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
        
--         for _,entity in pairs(controlled) do
--                 if entity.ClientCharacter and entity.ClientCharacter.OwnerUserID == 1 then
--                         return entity
--                 end
--         end

--         return nil
-- end