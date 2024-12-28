SceneControl = {}
SceneControl.__index = SceneControl
function SceneTab:NewSceneControl(Scene)
    local id = #self.ActiveSceneControls + 1
    local instance = setmetatable({
        ID = id,
        Scene = Scene,
        Window = Ext.IMGUI.NewWindow(id),
        Buttons = {}
    }, SceneControl)
    local involved = instance.Scene.entities
    if involved[1] and type(involved[1]) == "string" then
        instance.Window.Label = "Scene: " .. involved[1]
        if involved[2] and type(involved[2]) == "string" then
            instance.Window.Label = "Scene: " .. involved[1] .. " + " .. involved[2]
        end
    end
    instance:Initialize()
    table.insert(self.ActiveSceneControls, instance)
    return instance
end

function UI.FindSceneControlByEntity()

end
function UI.FetchScenes()
    UIEvents.FetchScenes:SendToServer("")
end

function SceneControl:Initialize()
    self.Window:SetSize({500, 500}, "FirstUseEver")
    self.Window.Closeable = true
    self.Window.OnClose = function (e)
        UIEvents.StopSex:SendToServer({ID = UIInstance.ID, Caster = self.Scene.entities[1]})
        self.Window:Destroy()
    end

    self.Animations = {} 
    self.AnimationPicker = {}
    
    self:CreateAnimationControlArea()
end

function SceneControl:AddControlButtons()
    local buttonTable = self.Window:AddTable("",5)
    local row = buttonTable:AddRow()
    local buttons = {
        "ChangePosition",
        "RotateScene",
        "ChangeCameraHeight",
        "MoveScene",
        "StopSex",
    }
    for _,button in pairs(buttons) do
        local controlButton = row:AddCell():AddButton(button)
        controlButton.OnClick = function()
           self:UseSceneControlButton(controlButton.Label) 
        end
    end
end

function SceneControl:UseSceneControlButton(buttonLabel)
    --local UI = UI.GetUIByID(self.UI)
    if buttonLabel == "ChangePosition" then
        UIInstance:AwaitInput("ChangePosition", self.Scene)
    elseif buttonLabel == "RotateScene" then
        UIInstance:AwaitInput("RotateScene", self.Scene)
        --UIEvents.RotateScene:SendToServer({ID = UIInstance.ID, Scene = self.Scene})

    elseif buttonLabel == "ChangeCameraHeight" then
        UIEvents.ChangeCameraHeight:SendToServer({ID = UIInstance.ID, Scene = self.Scene})

    elseif buttonLabel == "MoveScene" then
        UIInstance:AwaitInput("MoveScene", self.Scene)
        --UIEvents.MoveScene:SendToServer({ID = UIInstance.ID, Scene = self.Scene})

    elseif buttonLabel == "StopSex" then
        self.Window.OnClose()
    end
end

-- Creates some initial buttons with their own events
-- Sends an Event to Server, requesting Animations 
function SceneControl:CreateAnimationControlArea()
    self:AddControlButtons()
    if UIInstance.Settings.ShowAllAnimations == true then
        UIEvents.FetchAllAnimations:SendToServer({ID = UIInstance.ID, SceneControl = self.ID, Caster = _C().Uuid.EntityUuid})
    elseif UIInstance.Settings.ShowAllAnimations ~= true then
        UIEvents.FetchAllAnimations:SendToServer({ID = UIInstance.ID, SceneControl = self.ID, Caster = _C().Uuid.EntityUuid})
    end
    --self:AddAnimationPicker()
end

local function getAllHeightmatchingAnims(heightmatchingtable)
    local hmiAnims = {}
    --Debug.Dump(heightmatchingtable)
    for bodyIdentifier,matchups in pairs(heightmatchingtable) do
        for bodyIdentifier2,anims in pairs(matchups) do
            if anims then
                if type(anims) == "string" then
                    table.insert(hmiAnims, anims)
                elseif type(anims) == "table" then
                    for _,anim in pairs(anims) do
                        table.insert(hmiAnims, anim)
                    end
                end
            end
        end
    end
    return hmiAnims
end
local function updateCombo(combo, val)
    local newIndex = combo.SelectedIndex + val
    if newIndex <= 0 then
        newIndex = #combo.Options
    elseif newIndex > #combo.Options then
        newIndex = 1
    end
    if combo.SelectedIndex == 0 then
        newIndex = 1
    end
    combo.SelectedIndex = newIndex
    combo.OnChange()
end

function SceneControl:AddAnimationPicker()
    local debugbefore = Debug.USEPREFIX
    Debug.USEPREFIX = false

    self.AnimationsTable = self.Window:AddTable("", 2)

    table.sort(self.Animations)
    for AnimationName,Animation in pairsByKeys(self.Animations) do

        local animRow = self.AnimationsTable:AddRow()
        local animName = animRow:AddCell():AddText(AnimationName)
        local buttonCell = animRow:AddCell()
        local allAnimAnims = getAllHeightmatchingAnims(Animation.Heightmatching)

        local animationPicker
        local previousButton = buttonCell:AddButton("<")
        previousButton.OnClick = function()
            updateCombo(animationPicker, -1)
        end
        previousButton.SameLine = true

        animationPicker = buttonCell:AddCombo("")
        animationPicker.Options = allAnimAnims
        animationPicker.SelectedIndex = 1
        animationPicker.OnChange = function ()
            if animationPicker.SelectedIndex ~= 0 then
                UIEvents.ChangeAnimation:SendToServer({
                    ID = UIInstance.ID,
                    Caster = _C().Uuid.EntityUuid,
                    Animation = animationPicker.Options[animationPicker.SelectedIndex + 1]
                })
            end
        end
        animationPicker.SameLine = true

        local nextButton = buttonCell:AddButton(">")
        nextButton.OnClick = function()
            updateCombo(animationPicker, 1)
        end
        nextButton.SameLine = true
        table.insert(self.AnimationPicker, {Previous = previousButton, AnimationPicker = animationPicker, Next = nextButton})
    end
    
    Debug.USEPREFIX = debugbefore
end