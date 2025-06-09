---@class SceneTab
---@field Tab ExtuiTabItem
SceneTab = {}
SceneTab.__index = SceneTab

function SceneTab:New(holder)
    if UI.SceneTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        Tab = holder:AddTabItem(Ext.Loca.GetTranslatedString("hc21d333db09549dbbd1fcfaa6fdecb2a2b09", "Scenes")),
        Scenes = {},
    }, SceneTab)
    return instance
end

function SceneTab:Init()
    --self:GetScenes()
    self:CreateNewSceneArea()
    self.ActiveSceneControls = {}
    -- if self.Scenes and #self.Scenes > 0 then
    --     for i,Scene in ipairs(self.Scenes) do
    --         self:NewSceneControl(Scene)
    --     end
    -- end
end

function SceneTab:GetScenes()
    self.AwaitingScenes = true
    Event.FetchScenes:SendToServer("")
end

function SceneTab:RefreshAvailableAnimations(animationTable, scene)
    local scene = scene or nil
    for _,SceneControl in pairs(self.ActiveSceneControls) do
        if scene then
            if SceneControl.Scene == scene then
                SceneControl.UpdatingAnimationPicker = true
                SceneControl.AnimationPicker.Options = {}
                for i,Animation in ipairs(animationTable) do
                    SceneControl.AnimationPicker.Options[i] = Animation
                end
                SceneControl.UpdatingAnimationPicker = false
            end
        else
            SceneControl.UpdatingAnimationPicker = true
            SceneControl.AnimationPicker.Options = {}
            for i,Animation in ipairs(animationTable) do
                SceneControl.AnimationPicker.Options[i] = Animation
            end
            SceneControl.UpdatingAnimationPicker = false
        end
    end
end

function SceneTab:CreateNewSceneArea()
    self.NoSceneText = self.Tab:AddText("No active scenes, create one by:\n1. Select a character in the UI.\n2. Click the BG3SX button.\n3. Select a character of your choice to start a scene with\n(In open world or UI)")

    self.SFWSceneButton = self.Tab:AddImageButton("\t " .. Ext.Loca.GetTranslatedString("hfea9831b6ec148f1a9ddd486c3a0257c0610", "Create SFW Scene"), "BG3SX_SFW_Scene", {75,75})
    self.SFWSceneButton:Tooltip():AddText("\t " .. Ext.Loca.GetTranslatedString("hfea9831b6ec148f1a9ddd486c3a0257c0610", "Create SFW Scene"))
    self.SFWSceneButton.OnClick = function()
        if self.NewSceneEligible == true then
            self:AwaitNewScene("SFW") -- Currently does the same as regular new scene button
        end
    end
    -- self.SFWSceneButton.Visible = false

    self.NSFWSceneButton = self.Tab:AddImageButton("\t" .. Ext.Loca.GetTranslatedString("hc266ca8031ad49239c1cc596692c5102c9ba", "Create NSFW Scene"), "BG3SX_ICON_MAIN", {75,75})
    self.NSFWSceneButton:Tooltip():AddText("\t" .. Ext.Loca.GetTranslatedString("hc266ca8031ad49239c1cc596692c5102c9ba", "Create NSFW Scene"))
    self.NSFWSceneButton.OnClick = function()
        if self.NewSceneEligible == true then
            self:AwaitNewScene("NSFW")
        end
    end
    self.NSFWSceneButton.SameLine = true

    self.NewSceneEligible = true
    self.ControlsText = self.Tab:AddText("Mouse:\nLeft click | Right click to cancel\nController:\nLeft stick to start targeting + A | B to cancel")
    self.ControlsText.SameLine = true

    self.ActiveScenesSeparator = self.Tab:AddSeparatorText(Ext.Loca.GetTranslatedString("hb393d16ea9494b2a8adfec48663c7512a69g", "Running Scenes"))
    self.ActiveScenesSeparator.Visible = false

    self.InfoText = self.Tab:AddText("")
    self.InfoText.Visible = false
end

function SceneTab:AwaitNewScene(type)
    if type == "SFW" then
        UI:AwaitInput("NewSFWScene")
    elseif type == "NSFW" then
        UI:AwaitInput("NewNSFWScene")
    end
end

function SceneTab:UpdateNoSceneText()
    -- print("updating")
    local stillOneActive
    -- print("elf.ActiveSceneControls? " ,self.ActiveSceneControls )
    if self.ActiveSceneControls then
        -- print("size of active scene ", #self.ActiveSceneControls)
        for _,sceneControl in pairs(self.ActiveSceneControls) do
            if sceneControl.Reference then
                -- print("Reference still exists ")
                stillOneActive = true
            end
        end
    end
    if stillOneActive then
        self.NoSceneText.Visible = false -- Keep it hidden
        self.ActiveScenesSeparator.Visible = true
    else
        self.ActiveScenesSeparator.Visible = false
        self.NoSceneText.Visible = true -- Show it again
    end
end

function SceneTab:DisableSceneButtons()
    self.NewSceneEligible = false
    self.SFWSceneButton.Tint = {0.69, 0.69, 0.69, 1.0} -- Greyed out
    self.NSFWSceneButton.Tint = {0.69, 0.69, 0.69, 1.0} -- Greyed out
    self.ControlsText.Visible = false
    UI:DisplayInfoText("Character is not whitelisted, please select a different character.")
end

function SceneTab:EnableSceneButtons()
    self.NewSceneEligible = true
    self.SFWSceneButton.Tint = {1.0, 1.0, 1.0, 1.0} -- Regular color
    self.NSFWSceneButton.Tint = {1.0, 1.0, 1.0, 1.0} -- Regular color
    self.ControlsText.Visible = false
    UI:HideInfoText()
end

-- Check all current scenes against all current SceneControls
-- Checks all current scenes entities against all current SceneControl entities
-- When a scene is found thats not active anymore, it will destroy the SceneControl
Event.SyncActiveScenes:SetHandler(function(SavedScenes)
    if SavedScenes and Table.TableSize(SavedScenes) > 0 then
        local isStillActive = {}
        for _,scene in pairs(SavedScenes) do
            for _,entity in pairs(scene.entities) do
                table.insert(isStillActive, entity)
            end
        end
        local destroyedScene = {}
        for _,activeSceneControl in pairs(UI.SceneControl.ActiveSceneControls) do
            local found
            for _,activeSceneControlEntity in pairs(activeSceneControl.Scene.entities) do
                for _,entity in pairs(isStillActive) do
                    if activeSceneControlEntity == entity then
                        found = true
                    end
                end
            end
            if not found then
                activeSceneControl:Destroy()
            end
        end
    else
        -- No active scenes, destroy all leftover SceneControls
        for _,activeSceneControl in pairs(UI.SceneControl.ActiveSceneControls) do
            activeSceneControl:Destroy()
        end
    end
end)

return SceneTab