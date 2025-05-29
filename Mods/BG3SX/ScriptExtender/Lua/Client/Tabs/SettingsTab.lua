---@class SettingsTab
---@field Tab ExtuiTabItem
---@field Init fun(self:SettingsTab)
SettingsTab = {}
SettingsTab.__index = SettingsTab

---@param holder ExtuiTabBar
function SettingsTab:New(holder)
    if UI.SettingsTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        Tab = holder:AddTabItem("Settings"),
    }, SettingsTab)
    return instance
end

function SettingsTab:Init()
    local generalSettingsGroup = self.Tab:AddGroup("GeneralSettings")

    ---------------------------------
    local showTabGroup = generalSettingsGroup:AddGroup("Tab Visibility")
    showTabGroup:AddText(Ext.Loca.GetTranslatedString("h053ec08807c449e5873fbad66bb709c2ead8", "Tab Visibility"))

    self:AddSettingBox(generalSettingsGroup, Ext.Loca.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs"), true, function(check)
        UI.NPCTab.Tab.Visible = check
    end)
    self:AddSettingBox(generalSettingsGroup, Ext.Loca.GetTranslatedString("hd3dd6bc5609a4d65a7f71567e596dc84b81d", "Whitelist"), false, function(check)
        UI.WhitelistTab.Tab.Visible = check
    end)
    self:AddSettingBox(generalSettingsGroup, Ext.Loca.GetTranslatedString("hb4507f4d6c634f08a5e4080b00b7c2a1fddb", "Debug"), false, function(check)
        UI.DebugTab.Tab.Visible = check
    end)

    ---------------------------------
    -- local sceneGroup = generalSettingsGroup:AddGroup("Scene Settings")
    -- sceneGroup:AddText(Ext.Loca.GetTranslatedString("hadd9c724632b4e41ae4dbd58686b8db1c17f", "Tab Settings"))

    -- self:AddSettingBox(sceneGroup, Ext.Loca.GetTranslatedString("ha5a309de2e9542b2999d70313cf9455ab451", "Show all animations regardless of scene type"), false, function(check)
    --     for _,SceneControl in pairs(UI.SceneControl.ActiveSceneControls) do
    --         SceneControl:UpdateAnimationPicker()
    --     end
    -- end)
end

function SettingsTab:AddSettingBox(group, label, defaultValue, callback)
    local checkBox = group:AddCheckbox(label)
    checkBox.Checked = defaultValue
    checkBox.OnChange = function()
        callback(checkBox.Checked)
    end
    return checkBox
end

function SettingsTab:AddSettingButton(group, label, callback)
    local button = group:AddButton(label)
    button.OnClick = function()
        callback()
    end
    return button
end

return SettingsTab