------------------------------------
        -- Init Classes --
------------------------------------

Ext.Require("Client/NPCSync.lua") -- NPC changes have to be synced on the client
-- Ext.Require("Shared/Data/AnimationSets.lua") -- To replicate our sets on the client


Ext.Require("Shared/_constructor.lua")

-- Ext.Require("Shared/_initData.lua")
Ext.Require("Shared/_initUtils.lua")

Ext.Require("Client/UIHelper.lua")
Ext.Require("Client/UI.lua")
Ext.Require("Client/PartyInterface.lua")
Ext.Require("Client/SceneTab.lua")
Ext.Require("Client/SceneControl.lua")
Ext.Require("Client/GenitalTab.lua")
Ext.Require("Client/SettingsTab.lua")
Ext.Require("Client/DebugTab.lua")

Ext.Require("Client/UIEventHandler.lua")



Ext.Require("Client/GenitalMessages.lua")





Ext.Vars.RegisterModVariable(ModuleUUID, "BG3SX_ShowAllAnimations", {
        Server = true, Client = true, SyncToClient = true
    })