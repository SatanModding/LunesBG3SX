
SettingsTab = {}
SettingsTab.__index = SettingsTab
function UI:NewSettingsTab()
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Settings"),
    }, SettingsTab)
    return instance
end

function SettingsTab:Initialize()
    self:AddHotKeySettings()
    self:AddSceneSettings()
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
            UIEvents.FetchAllAnimations:SendToServer({ID = UIInstance.ID})
        else
            -- TODO - send the .Filter in the payload
            UIEvents.FetchFilteredAnimations:SendToServer({ID = UIInstance.ID})
        end
    elseif Checkbox.Label == "Automatic Erections" then
        if Checkbox.Checked == true then
            UIEvents.AutoErectionOn:SendToServer({ID = UIInstance.ID})
        else
            UIEvents.AutoErectionOff:SendToServer({ID = UIInstance.ID})
        end
    end
end