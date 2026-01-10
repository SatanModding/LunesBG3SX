---@class SettingsTab
---@field Tab ExtuiTabItem
---@field CustomSettings table<string, table[]>
---@field Init fun(self:SettingsTab)
---@field AddSettingBox fun(self:SettingsTab, group:ExtuiGroup, label:string, defaultValue:boolean, tableKey:string, property:string, callback:function):ExtuiCheckbox
---@field InitCustomSettings fun(self:SettingsTab)
---@field UpdateCustomSettings fun(self:SettingsTab)
---@field RegisterCustomSetting fun(self:SettingsTab, modUUID:string, label:string, defaultValue:boolean, tableKey:string, property:string, callback:function)
---@field GenerateCredits fun(self:SettingsTab)
SettingsTab = {}
SettingsTab.__index = SettingsTab

---@param holder ExtuiTabBar
function SettingsTab:New(holder)
    if UI.SettingsTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        Tab = holder:AddTabItem(Locale.GetTranslatedString("hedf73cea14534ece90bc4da1cc5f647d58e8", "Settings")),
        CustomSettings = {},
    }, SettingsTab)
    return instance
end

function SettingsTab:Init()
    local generalSettingsGroup = self.Tab:AddGroup("GeneralSettings")

    ---------------------------------
    local showTabGroup = generalSettingsGroup:AddGroup("Tab Visibility")
    showTabGroup:AddSeparatorText(Locale.GetTranslatedString("h053ec08807c449e5873fbad66bb709c2ead8", "Tab Visibility"))

    self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs"), true, "Tab_NPC", "Visible", function(checked)
        UI.NPCTab.Tab.Visible = checked
    end)

    local box = self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("hd3dd6bc5609a4d65a7f71567e596dc84b81d", "Whitelist"), false, "Tab_Whitelist", "Visible", function(checked)
        UI.WhitelistTab.Tab.Visible = checked
    end)
    box.SameLine = true

    local box = self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("hb4507f4d6c634f08a5e4080b00b7c2a1fddb", "Debug"), false, "Tab_Debug", "Visible", function(checked)
        UI.DebugTab.Tab.Visible = checked
    end)
    box.SameLine = true

    ---------------------------------
    local showSceneGroup = generalSettingsGroup:AddGroup("Scene Tab Settings")
    showSceneGroup:AddSeparatorText(Locale.GetTranslatedString("h0388b3f9379841729a475c3b264d4cc96622", "Scene Tab Settings"))
    self.NoSceneTextCheckbox = self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("h1e4d1ff989ab4d5b9aedfe5d67d4b25cba8e", "Show 'How To'"), true, "Tab_Scenes", "NoSceneText_Visible", function(checked)
        if UI.SceneTab and UI.SceneTab.NoSceneText then
            UI.SceneTab.NoSceneText.Visible = checked
        end
    end)

    ---------------------------------
    local sceneGroup = generalSettingsGroup:AddGroup("NPCTab Settings")
    sceneGroup:AddSeparatorText(Locale.GetTranslatedString("hb21edb40a9044ddcb50f2557b6a00ae27933", "NPC Tab Settings"))

    UI.Settings.AutomaticNPCScan = self:AddSettingBox(generalSettingsGroup, Locale.GetTranslatedString("hb2022efb943c40ee8e6a8bb9f354eb308d46", "Automatic NPC Scan"), false, "Tab_NPC", "AutomaticScan", function(checked)
        if checked then
            UI.NPCTab.ManualScan.Visible = false
        else
            UI.NPCTab.ManualScan.Visible = true
        end
    end)
    UI.Settings.AutomaticNPCScan:Tooltip():AddText(Locale.GetTranslatedString("h96863be65f494a9ea56759ea763b38f06520", "Disabling this settings creates a manual 'Scan' button in the NPC Tab."))

    self:InitCustomSettings()
    self:GenerateCredits()
end

-- Persistent checkbox backed by LocalSettings
-- Gets/sets tableKey as a table in LocalSettings.Data (e.g., Tab_NPC, Tab_Scenes)
-- and stores property within that table
function SettingsTab:AddSettingBox(group, label, defaultValue, tableKey, property, callback)
    local checkBox = group:AddCheckbox(label)
    
    -- Get the settings table for this key, or create empty one
    local settingsTable = LocalSettings:GetOr({}, tableKey)
    
    -- Get the property value or use default
    local checked = settingsTable[property]
    if checked == nil then
        checked = defaultValue
    end
    
    checkBox.Checked = checked
    --callback(checked) -- Might break if ui is loaded and this is called before LevelGameplayStarted server event
    -- Currently every setting box is only created, the callback is only called when changed
    -- We need to call it once after levelgameplaystarted if we want to apply saved setting values
    -- I think
    
    checkBox.OnChange = function(val)
        local newVal
        if type(val) == "boolean" then
            checkBox.Checked = val
            newVal = val
        else
            newVal = checkBox.Checked
        end
        settingsTable[property] = newVal
        LocalSettings:AddOrChange(tableKey, settingsTable)
        callback(newVal)
    end
    return checkBox
end

function SettingsTab:InitCustomSettings()
    self.CustomSettingsHeader = self.Tab:AddSeparatorText(Locale.GetTranslatedString("h1539e8a9f0294d5194d3ef49318e2874bcc4", "Custom Settings"))
    self.CustomSettingsGroup = self.Tab:AddGroup("CustomSettings")
    self.CustomSettingsHeader.Visible = false
    if #self.CustomSettings > 0 then
        self:UpdateCustomSettings()
    end
    self.CustomSettingsAreaReady = true
end
-- In case we need to refresh the custom settings UI
function SettingsTab:UpdateCustomSettings()
    UI.DestroyChildren(self.CustomSettingsGroup)
    if self.CustomSettings == nil then return end
    self.CustomSettingsHeader.Visible = false
    for modUuid, settings in pairs(self.CustomSettings) do
        local modInfo = Ext.Mod.GetMod(modUuid)
        local modName = modInfo and modInfo.Info.Name or modUuid
        local modHeader = self.CustomSettingsGroup:AddCollapsingHeader(modName)
        local modGroup = modHeader:AddGroup(modUuid.."SettingsGroup")
        
        -- Add each setting for this mod under its header
        for _, setting in ipairs(settings) do
            if setting.SettingType == "CheckBox" then
                self:AddSettingBox(modGroup, setting.Label, setting.DefaultValue, setting.LocalSettingsKey, setting.LocalSettingsField, setting.Callback)
            end
        end
    end
end

---@class CustomSettingParams
---@field ModUuid string
---@field Label string
---@field DefaultValue boolean
---@field LocalSettingsKey string
---@field LocalSettingsField string
---@field Callback fun(checked:boolean)

-- Register a custom setting from an addon mod
---@param args CustomSettingParams
function SettingsTab:RegisterCustomSetting(args)
    -- Initialize settings array for this mod if needed
    if args and args.ModUuid and not self.CustomSettings[args.ModUuid] then
        self.CustomSettings[args.ModUuid] = {}
    end
    
    -- Add the setting to this mod's settings
    table.insert(self.CustomSettings[args.ModUuid], {
        SettingType = "CheckBox",-- Currently only CheckBox is supported
        Label = args.Label,
        DefaultValue = args.DefaultValue,
        LocalSettingsKey = args.LocalSettingsKey,
        LocalSettingsField = args.LocalSettingsField,
        Callback = args.Callback
    })
    if self.CustomSettingsAreaReady then
        self:UpdateCustomSettings()
    end
end
-- Call via:
-- client context
-- Mods.BG3SX.UI.SettingsTab:RegisterCustomSetting({ModUuid = ModuleUUID, Label = "MySetting", DefaultValue = true/false, LocalSettingsKey = tableKey, LocalSettingsField = property, Callback = callback})
-- Use Locale.GetTranslatedString(handle, fallbackString) for label to make it translatable
-- Whenever we may provide other setting types in the future (buttons, sliders), you can also register by giving us a SettingType

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
