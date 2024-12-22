--Event Creation
function UIEvents:Initialize()
    self.FetchScenes = Ext.Net.CreateChannel(ModuleUUID, "FetchScenes")
    self.SendScenes = Ext.Net.CreateChannel(ModuleUUID, "SendScenes")
end
UIEvents:Initialize()