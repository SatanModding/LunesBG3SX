---@class SettingsTab
---@field Tab ExtuiTabItem
---@field Init fun(self:SettingsTab)
SettingsTab = {}
SettingsTab.__index = SettingsTab

---@param holder ExtuiTabBar
function SettingsTab:New(holder)
    if UI.SettingsTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        Tab = holder:AddTabItem(Locale.GetTranslatedString("hedf73cea14534ece90bc4da1cc5f647d58e8", "Settings")),
    }, SettingsTab)
    return instance
end

function SettingsTab:Init()
    local generalSettingsGroup = self.Tab:AddGroup("GeneralSettings")

    ---------------------------------
    local showSceneGroup = generalSettingsGroup:AddGroup("Scene Tab Settings")
    showSceneGroup:AddSeparatorText(Locale.GetTranslatedString("h0388b3f9379841729a475c3b264d4cc96622", "Scene Tab Settings"))
    self:AddSettingButton(generalSettingsGroup, Locale.GetTranslatedString("h1e4d1ff989ab4d5b9aedfe5d67d4b25cba8e", "Show 'How To' again"), function()
        UI.SceneTab.NoSceneText.Visible = true
    end)

    ---------------------------------
    local showTabGroup = generalSettingsGroup:AddGroup("Tab Visibility")
    showTabGroup:AddSeparatorText(Locale.GetTranslatedString("h053ec08807c449e5873fbad66bb709c2ead8", "Tab Visibility"))

    self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs"), true, function(checked)
        UI.NPCTab.Tab.Visible = checked
    end)

    local box = self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("hd3dd6bc5609a4d65a7f71567e596dc84b81d", "Whitelist"), false, function(checked)
        UI.WhitelistTab.Tab.Visible = checked
    end)
    box.SameLine = true

    local box = self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("hb4507f4d6c634f08a5e4080b00b7c2a1fddb", "Debug"), false, function(checked)
        UI.DebugTab.Tab.Visible = checked
    end)
    box.SameLine = true

    ---------------------------------
    local sceneGroup = generalSettingsGroup:AddGroup("NPCTab Settings")
    sceneGroup:AddSeparatorText(Locale.GetTranslatedString("hb21edb40a9044ddcb50f2557b6a00ae27933", "NPC Tab Settings"))

    UI.Settings.AutomaticNPCScan = self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("hb2022efb943c40ee8e6a8bb9f354eb308d46", "Automatic NPC Scan"), false, function(checked)
       if checked then
            UI.NPCTab.ManualScan.Visible = false
        else
            UI.NPCTab.ManualScan.Visible = true
        end
    end)
    UI.Settings.AutomaticNPCScan:Tooltip():AddText(Locale.GetTranslatedString("h96863be65f494a9ea56759ea763b38f06520", "Disabling this settings creates a manual 'Scan' button in the NPC Tab."))

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
    creditsGroup:AddSeparatorText(Locale.GetTranslatedString("hd1aa350cf2bf4942b9be983b18920e88g247", "Credits"))

    creditsGroup:AddText(Locale.GetTranslatedString("h554123bc72a54633ad9d1768c065e80d4431", "This mod was created with a lot of help by the amazing BG3 Modding Community,\nbut we would like to thank a few contributors specifically:"))
    creditsGroup:AddText(Locale.GetTranslatedString("h89d4bb3b5a474a2b80143206bfeb07821c8a", "Contributors: kit, ltpitb, Aahz, Volitio, Velvy, Lunisole, LaughingLeader, Norbyte"))
    creditsGroup:AddText(Locale.GetTranslatedString("h2f2930940303487eb3355ef98472ddcdg8d0", "If you would like to contribute, please join our Discord server:"))
    local discordLink = creditsGroup:AddInputText("")
    discordLink.Text = "https://discord.gg/ChndmEPUpt"
    -- discordLink.SameLine = true
end

return SettingsTab
