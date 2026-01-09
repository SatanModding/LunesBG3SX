---@class DebugTab
---@field Tab ExtuiTabItem
DebugTab = {}
DebugTab.__index = DebugTab
function DebugTab:New(holder)
    if UI.DebugTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        Tab = holder:AddTabItem(Locale.GetTranslatedString("hb4507f4d6c634f08a5e4080b00b7c2a1fddb", "Debug")),
    }, DebugTab)
    return instance
end

function DebugTab:Init()
    local generalSettingsGroup = self.Tab:AddGroup("GeneralDebug")

    ---------------------------------
    local showTabGroup = generalSettingsGroup:AddGroup("Scene Debug")
    showTabGroup:AddText(Locale.GetTranslatedString("h89052b2849e84a10b8c2c9b0c6e431daf53g", "Scene Debug"))

    self:AddSettingButton(generalSettingsGroup, Locale.GetTranslatedString("h2993f96bb07749708dd673c5bb49027dbagc", "Destroy All Scenes"), function()
        Event.DestroyAllScenes:SendToServer()
    end)

    if Ext.Debug.IsDeveloperMode() then
        self:AddSettingButton(generalSettingsGroup, Locale.GetTranslatedString("h3ca7538e44cc443d8b5dafc1924842305f17", "DeveloperMode Reset"), function()
            Ext.Debug.Reset()
        end)
    end
end

function DebugTab:AddSettingBox(group, label, defaultValue, callback)
    local checkBox = group:AddCheckbox(label)
    checkBox.Checked = defaultValue
    checkBox.OnChange = function()
        callback(checkBox.Checked)
    end
    return checkBox
end

function DebugTab:AddSettingButton(group, label, callback)
    local button = group:AddButton(label)
    button.OnClick = function()
        callback()
    end
    return button
end

return DebugTab
