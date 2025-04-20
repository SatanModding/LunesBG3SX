
SceneTab = {}
SceneTab.__index = SceneTab
function UI:NewSceneTab()
    if self.SceneTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem(Ext.Loca.GetTranslatedString("hc21d333db09549dbbd1fcfaa6fdecb2a2b09", "Scenes")),
        Scenes = {},
    }, SceneTab)
    return instance
end

function SceneTab:Initialize()
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

-- Goes through every currently running scene until it finds the entityToSearch
---@param entityToSearch string
function SceneTab:FindSceneControlByEntity(entityToSearch)
    for _,SceneControl in pairs(self.ActiveSceneControls) do
        for _, entity in pairs(SceneControl.Scene.entities) do
            if Helper.StringContainsOne(entityToSearch, entity) then
                _P("Found scene control for entity: ", entityToSearch)
                return SceneControl
            end
        end
    end
end

function SceneTab:CreateNewSceneArea()
    self.NoSceneText = self.Tab:AddText("No active scenes, create one by:\n1. Select a character in the UI.\n2. Click the BG3SX button.\n3. Select a character of your choice to start a scene with\n(In open world or UI)")

    self.SFWSceneButton = self.Tab:AddImageButton("Create SFW Scene", "Action_Song_BardDance", {100,100})
    self.SFWSceneButton:Tooltip():AddText("Create SFW Scene")
    self.SFWSceneButton.OnClick = function()
        self:AwaitNewScene() -- Currently does the same as regular new scene button
    end
    self.SFWSceneButton.Visible = false

    self.NSFWSceneButton = self.Tab:AddImageButton(Ext.Loca.GetTranslatedString("hc266ca8031ad49239c1cc596692c5102c9ba", "Create Scene"), "BG3SX_ICON_MAIN", {100,100})
    self.NSFWSceneButton:Tooltip():AddText(Ext.Loca.GetTranslatedString("hc266ca8031ad49239c1cc596692c5102c9ba", "Create Scene"))
    self.NSFWSceneButton.OnClick = function()
        self:AwaitNewScene()
    end
    -- self.NSFWSceneButton.SameLine = true

    self.ControlsText = self.Tab:AddText("Mouse:\nLeft click | Right click to cancel\nController:\nLeft stick to start targeting + A | B to cancel")
    self.ControlsText.SameLine = true

    self.InfoText = self.Tab:AddText("")
    self.InfoText.Visible = false
end

function SceneTab:AwaitNewScene()
    UIInstance:AwaitInput("NewScene")
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
    else
        self.NoSceneText.Visible = true -- Show it again
    end
end

-- Check all current scenes against all current SceneControls
-- Checks all current scenes entities against all current SceneControl entities
-- When a scene is found thats 
Event.SyncActiveScenes:SetHandler(function(SavedScenes)
    if SavedScenes and #SavedScenes > 0 then
        local isStillActive = {}
        for _,scene in pairs(SavedScenes) do
            for _,entity in pairs(scene.entities) do
                table.insert(isStillActive, entity)
            end
        end
        local destroyedScene = {}
        for _,activeSceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
            local found
            for _,activeSceneControlEntity in pairs(activeSceneControl.Scene.entities) do
                for _,entity in pairs(isStillActive) do
                    if activeSceneControl == entity then
                        found = true
                    end
                end
            end
            if not found then
                activeSceneControl:Destroy()
            end
        end
    else
        -- No active scenes, destroy all scene controls
        UIInstance.SceneTab.ActiveSceneControls = {}
    end
end)