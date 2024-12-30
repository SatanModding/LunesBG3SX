
SceneTab = {}
SceneTab.__index = SceneTab
function UI:NewSceneTab()
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Scenes"),
        Scenes = {},
    }, SceneTab)
    return instance
end

function SceneTab:Initialize()
    --self:GetScenes()
    self.NewSceneArea = self:CreateNewSceneArea()
    self.ActiveSceneControls = {}
    if self.Scenes and #self.Scenes > 0 then
        for i,Scene in ipairs(self.Scenes) do
            self:NewSceneControl(Scene)
        end
    end
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
    local sceneTable = self.Tab:AddTable("", 1)
    self.NoSceneText = sceneTable:AddRow():AddCell():AddText("No Scenes found, create one!")
    self.CreateSceneButton = sceneTable:AddRow():AddCell():AddButton("Create Scene")
    self.CreateSceneButton.OnClick = function()
        self:AwaitNewScene()
    end
    -- self.DestroySceneButton = Table.AddRow():AddCell():AddButton("End Scene")
    -- self.DestroySceneButton.OnClick = function()
    --     UIEvents.StopSex:SendToServer({ID = USERID, Caster = _C().Uuid.EntityUuid})
    -- end
    return sceneTable
end

function SceneTab:AwaitNewScene()
    UIInstance:AwaitInput("NewScene")
end