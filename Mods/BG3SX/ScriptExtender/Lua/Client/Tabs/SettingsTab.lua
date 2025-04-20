SettingsTab = {}
SettingsTab.__index = SettingsTab
function UI:NewSettingsTab()
    if self.SettingsTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Settings"),
    }, SettingsTab)
    return instance
end

function SettingsTab:Initialize()
    local generalSettingsGroup = self.Tab:AddGroup("GeneralSettings")

    ---------------------------------
    local showTabGroup = generalSettingsGroup:AddGroup("Tab Visibility")
    showTabGroup:AddText(Ext.Loca.GetTranslatedString("h053ec08807c449e5873fbad66bb709c2ead8", "Tab Visibility"))

    self.ShowWhitelistTab = generalSettingsGroup:AddCheckbox(Ext.Loca.GetTranslatedString("hd3dd6bc5609a4d65a7f71567e596dc84b81d", "Whitelist"))
    self.ShowWhitelistTab.Checked = UIInstance.WhitelistTab.Tab.Visible
    self.ShowWhitelistTab.OnChange = function(check)
        UIInstance.WhitelistTab.Tab.Visible = check.Checked
    end
    self.ShowNPCTab = generalSettingsGroup:AddCheckbox(Ext.Loca.GetTranslatedString("h3d507f295c0b468ea6429b9b00c3c4ed2534", "NPCs"))
    self.ShowNPCTab.Checked = UIInstance.NPCTab.Tab.Visible
    self.ShowNPCTab.OnChange = function(check)
        UIInstance.NPCTab.Tab.Visible = check.Checked
    end

    ---------------------------------
    local sceneGroup = generalSettingsGroup:AddGroup("Scene Settings")
    sceneGroup:AddText(Ext.Loca.GetTranslatedString("hadd9c724632b4e41ae4dbd58686b8db1c17f", "Tab Settings"))
    self.UnlockedAnimations = generalSettingsGroup:AddCheckbox(Ext.Loca.GetTranslatedString("ha5a309de2e9542b2999d70313cf9455ab451", "Show all animations regardless of scene type"))
    self.UnlockedAnimations.Checked = false
    self.UnlockedAnimations.OnChange = function(check)
        for _,SceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
            SceneControl:UpdateAnimationPicker()
        end
    end


    -- self:AddHotKeySettings()
    -- self:AddSceneSettings()
end

function SettingsTab:AddHotKeySettings()
    --local UI = UI.GetUIByID(self.UI)
    self.Tab:AddText("Hotkeys")
    UIInstance.HotKeys.Select = self.Tab:AddCombo("Select - While awaiting Input")
    --Debug.DumpS(UI.HotKeys)
    local combo = UIInstance.HotKeys.Select
    for i,key in ipairs(Ext.Enums.SDLScanCode) do
        if not key == "UNKNOWN" then -- So this doesn't become selectable
            combo.Options[i] = key
        end
    end
    combo.OnChange = function()
        Debug.Print("Hotkey Changed to " .. combo.Value)
    end
end

function SettingsTab:AddSceneSettings()
    local t = self.Tab:AddTable("", 1):AddRow():AddCell()
    local checkBoxes = {
        "Show All Animations",
        --"Automatic Erections"
    }
    for _,box in pairs(checkBoxes) do
        local settingsCheckbox = t:AddCheckbox(box)
        settingsCheckbox.Checked = false
        if settingsCheckbox.Label == "Show All Animations" then
            local animInfo = t:AddText(" - May Show some that don't line up correctly")
            animInfo.SameLine = true
        end
        settingsCheckbox.OnChange = function()
            self:SetSceneSettings(settingsCheckbox)
        end
    end
end

function SettingsTab:SetSceneSettings(Checkbox)
    if Checkbox.Label == "Show All Animations" then
        if Checkbox.Checked == true then
            Event.FetchAllAnimations:SendToServer({ID = USERID})
        else
            -- TODO - send the .Filter in the payload
            Event.FetchFilteredAnimations:SendToServer({ID = USERID})
        end
    elseif Checkbox.Label == "Automatic Erections" then
        if Checkbox.Checked == true then
            Event.AutoErectionOn:SendToServer({ID = USERID})
        else
            Event.AutoErectionOff:SendToServer({ID = USERID})
        end
    end
end