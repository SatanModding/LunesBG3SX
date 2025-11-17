---@class SettingsTab
---@field Tab ExtuiTabItem
---@field Init fun(self:SettingsTab)
SettingsTab = {}
SettingsTab.__index = SettingsTab

---@param holder ExtuiTabBar
function SettingsTab:New(holder)
    if UI.SettingsTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        Tab = holder:AddTabItem(Ext.Loca.GetTranslatedString("hedf73cea14534ece90bc4da1cc5f647d58e8", "Settings")),
    }, SettingsTab)
    return instance
end

function SettingsTab:Init()
    local generalSettingsGroup = self.Tab:AddGroup("GeneralSettings")

    ---------------------------------
    local showTabGroup = generalSettingsGroup:AddGroup("Tab Visibility")
    showTabGroup:AddSeparatorText(Ext.Loca.GetTranslatedString("h053ec08807c449e5873fbad66bb709c2ead8", "Tab Visibility"))

    self:AddSettingBox(generalSettingsGroup, Ext.Loca.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs"), true, function(checked)
        UI.NPCTab.Tab.Visible = checked
    end)

    local box = self:AddSettingBox(generalSettingsGroup, Ext.Loca.GetTranslatedString("hd3dd6bc5609a4d65a7f71567e596dc84b81d", "Whitelist"), false, function(checked)
        UI.WhitelistTab.Tab.Visible = checked
    end)
    box.SameLine = true

    local box = self:AddSettingBox(generalSettingsGroup, Ext.Loca.GetTranslatedString("hb4507f4d6c634f08a5e4080b00b7c2a1fddb", "Debug"), false, function(checked)
        UI.DebugTab.Tab.Visible = checked
    end)
    box.SameLine = true

    ---------------------------------
    local sceneGroup = generalSettingsGroup:AddGroup("NPCTab Settings")
    sceneGroup:AddSeparatorText(Ext.Loca.GetTranslatedString("hb21edb40a9044ddcb50f2557b6a00ae27933", "NPCTab Settings"))

    UI.Settings.AutomaticNPCScan = self:AddSettingBox(generalSettingsGroup, Ext.Loca.GetTranslatedString("hb2022efb943c40ee8e6a8bb9f354eb308d46", "Automatic NPC Scan"), false, function(checked)
       if checked then
            UI.NPCTab.ManualScan.Visible = false
        else
            UI.NPCTab.ManualScan.Visible = true
        end
    end)
    UI.Settings.AutomaticNPCScan:Tooltip():AddText(Ext.Loca.GetTranslatedString("h96863be65f494a9ea56759ea763b38f06520", "Disabling this settings creates a manual 'Scan' button in the NPC Tab."))

    self:GenerateCredits()
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

function SettingsTab:GenerateCredits()
    local creditsGroup = self.Tab:AddGroup("Credits")
    creditsGroup:AddSeparatorText(Ext.Loca.GetTranslatedString("hd1aa350cf2bf4942b9be983b18920e88g247", "Credits"))

    creditsGroup:AddText(Ext.Loca.GetTranslatedString("h554123bc72a54633ad9d1768c065e80d4431", "This mod was created with a lot of help by the amazing BG3 Modding Community,\nbut we would like to thank a few contributors specifically:"))
    creditsGroup:AddText(Ext.Loca.GetTranslatedString("h89d4bb3b5a474a2b80143206bfeb07821c8a", "Contributors: kit, ltpitb, Aahz, Volitio, Lunisole, LaughingLeader, Norbyte"))
    creditsGroup:AddText(Ext.Loca.GetTranslatedString("h2f2930940303487eb3355ef98472ddcdg8d0", "If you would like to contribute, please join our Discord server:"))
    local discordLink = creditsGroup:AddInputText("")
    discordLink.Text = "https://discord.gg/ChndmEPUpt"
    -- discordLink.SameLine = true
end

return SettingsTab