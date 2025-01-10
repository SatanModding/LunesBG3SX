
SceneTab = {}
SceneTab.__index = SceneTab
function UI:NewSceneTab()
    if self.SceneTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Scenes"),
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
    UIEvents.FetchScenes:SendToServer("")
end

function SceneTab:RefreshAvailableAnimations(targetSceneControl, animationTable)
    for _,SceneControl in pairs(self.ActiveSceneControls) do
        SceneControl.UpdatingAnimationPicker = true
        SceneControl.AnimationPicker.Options = {}
        for i,Animation in ipairs(animationTable) do
            SceneControl.AnimationPicker.Options[i] = Animation
        end
        SceneControl.UpdatingAnimationPicker = false
    end
end

function SceneTab:CreateNewSceneArea()
    self.NoSceneText = self.Tab:AddText("No Scenes found, create one!")

    self.SFWSceneButton = self.Tab:AddImageButton("Create SFW Scene", "Action_Song_BardDance", {100,100})
    self.SFWSceneButton:Tooltip():AddText("Create SFW Scene")
    self.SFWSceneButton.OnClick = function()
        self:AwaitNewScene() -- Currently does the same as regular new scene button
    end
    self.SFWSceneButton.Visible = false

    self.NSFWSceneButton = self.Tab:AddImageButton("Create Scene", "BG3SX_ICON_MAIN", {100,100})
    self.NSFWSceneButton:Tooltip():AddText("Create Scene")
    self.NSFWSceneButton.OnClick = function()
        self:AwaitNewScene()
    end
    -- self.NSFWSceneButton.SameLine = true
end

function SceneTab:AwaitNewScene()
    UIInstance:AwaitInput("NewScene")
end

function SceneTab:UpdateNoSceneText()
    print("updating")
    local stillOneActive
    print("elf.ActiveSceneControls? " ,self.ActiveSceneControls )
    if self.ActiveSceneControls then
        print("size of active scene ", #self.ActiveSceneControls)
        for _,sceneControl in pairs(self.ActiveSceneControls) do
            if sceneControl.Reference then
                print("Reference still exists ")
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