SceneControl = {}
SceneControl.__index = SceneControl
function SceneTab:NewSceneControl(Scene)
    -- Check if there are any viable leftover SceneControl instances
    if self.ActiveSceneControls and #self.ActiveSceneControls > 0 then
        for _,sceneControl in pairs(self.ActiveSceneControls) do
            if sceneControl.Unused then
                sceneControl.Scene = Scene
                sceneControl.Window.Open = true
                sceneControl:UpdateWindowName()
                sceneControl:Initialize()
                sceneControl.Unused = nil
                return sceneControl
            end
        end
    end
    -- If no viable leftover was found, create a new one
    --_DS(self.ActiveSceneControls)
    --_P("ActiveSceneControls " .. #self.ActiveSceneControls)
    local id = #self.ActiveSceneControls + 1  -- this seems wonky. It always increases
    local instance = setmetatable({
        ID = id,
        Scene = Scene, --check if it needs to be updated when scene changes or iif this points to the original one
        Window = Ext.IMGUI.NewWindow(id),
        }, SceneControl)
    instance:UpdateWindowName()
    table.insert(self.ActiveSceneControls, {Instance = instance})
    instance:Initialize()
    return instance
end

function SceneControl:UpdateWindowName()
    local involved = self.Scene.entities
    if involved[1] and type(involved[1]) == "string" then
        self.Window.Label = "Window " .. self.ID .. " - Scene: " .. Helper.GetName(involved[1])
        if involved[2] and type(involved[2]) == "string" then
            self.Window.Label = "Window " .. self.ID .. " - Scene: " .. Helper.GetName(involved[1]) .. " + " .. Helper.GetName(involved[2])
        end
    end
end

function UI.FindSceneControlByEntity()

end

function UI.FetchScenes()
    UIEvents.FetchScenes:SendToServer("")
end

-- Resets the SceneControl instance
-- Only the window and SceneControl ID remains
-- Windows currently can't be destroyed so its closed instead
-- On new SceneControl creation, pick up on if there are any empty ones and use these first before creating a new one
function SceneControl:Destroy()
    UIEvents.StopSex:SendToServer({ID = self.ID, Scene = self.Scene})
    for _,SceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
        if SceneControl.Instance == self then
            SceneControl.Reference:Destroy() -- Delete SceneTab Reference Imgui Element
            SceneControl.Reference = nil -- Set to nil for NoSceneText update
            UIInstance.SceneTab:UpdateNoSceneText()
        end
    end
    for componentName,component in pairs(self) do
        if (component ~= self.ID) and (component ~= self.Window) then
            component = nil
        elseif component == self.Window then
            UI.DestroyChildren(self.Window)
            self.Window.Open = false
            --self.Window:Destroy()
        end
    end
    self.Unused = true
    --self = nil
end

function SceneControl:Initialize()
    -- Don't have to redo basic Window settings if it was used before, thats why we reset this value after initialization
    if not self.Unused then
        self.Window:SetSize({500, 500}, "FirstUseEver")
        -- self.Window:SetStyle("WindowRounding", 4.0)
        self.Window.Closeable = true
        self.Window.OnClose = function ()
            self.Window.Open = false
        end
    end

    self.Animations = {} 
    self.AnimationPicker = {}
    self:CreateAnimationControlArea()
    self:CreateSceneTabReference()
end

function SceneControl:CreateSceneTabReference()
    local refGroup = UIInstance.SceneTab.Tab:AddGroup("")
    local openButton = refGroup:AddButton("Open")
    local closeButton = refGroup:AddButton("Close")
    local ref = refGroup:AddText(self.Window.Label)
    closeButton.SameLine = true
    ref.SameLine = true
    openButton.OnClick = function()
        self.Window.Open = true
    end
    closeButton.OnClick = function()
        self:Destroy()
    end
    for _,SceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
        if SceneControl.Instance == self then
            SceneControl.Reference = refGroup
        end
    end
end

function SceneControl:AddControlButtons()
    local buttons = {
        ["Swap Position"] = "BG3SX_ICON_Scene_SwitchPlaces",
        ["Rotate Scene"] = "BG3SX_ICON_Scene_Rotate",
        --"Change Camera Height",
        ["Move Scene"] = "BG3SX_ICON_Scene_Move",
        ["Stop Sex"] = "BG3SX_ICON_Scene_End",
    }
    for buttonName,buttonIcon in pairs(buttons) do
        local iconButton = self.Window:AddImageButton(buttonName, buttonIcon, {50,50})
        iconButton.SameLine = true
        iconButton.OnClick = function()
           self:UseSceneControlButton(iconButton.Label) 
        end
        iconButton:Tooltip():AddText(iconButton.Label)
    end
end

function SceneControl:UseSceneControlButton(buttonLabel)
    --local UI = UI.GetUIByID(self.UI)
    if buttonLabel == "Swap Position" then
        UIEvents.SwapPosition:SendToServer({ID = USERID, Scene = self.Scene})
    elseif buttonLabel == "Rotate Scene" then
        UIInstance:AwaitInput("RotateScene", self.Scene)
    elseif buttonLabel == "Change Camera Height" then
        UIEvents.ChangeCameraHeight:SendToServer({ID = USERID})
    elseif buttonLabel == "Move Scene" then
        UIInstance:AwaitInput("MoveScene", self.Scene)
    elseif buttonLabel == "Stop Sex" then
        self:Destroy()
    end
end

-- Creates some initial buttons with their own events
-- Sends an Event to Server, requesting Animations 
function SceneControl:CreateAnimationControlArea()
    self:AddControlButtons()
    if UIInstance.Settings.ShowAllAnimations == true then
        UIEvents.FetchAllAnimations:SendToServer({ID = USERID, SceneControl = self.ID, Caster = _C().Uuid.EntityUuid})
    elseif UIInstance.Settings.ShowAllAnimations ~= true then
        UIEvents.FetchAllAnimations:SendToServer({ID = USERID, SceneControl = self.ID, Caster = _C().Uuid.EntityUuid})
    end
    self.Window:AddSeparator("")

    -- Filter Area
    self.Filter = {}
    local byMod = self.Window:AddCheckbox("Filter by Mod")
    byMod.Checked = false
    self.Filter.Mod = byMod
    
    local byCategory = self.Window:AddCheckbox("Filter by Category")
    byCategory.Checked = false
    byCategory.SameLine = true
    self.Filter.Category = byCategory

    local modPicker = self.Window:AddCombo("Choose Mod")
    modPicker.Visible = false
    self.Filter.ModPicker = modPicker

    local categoryPicker = self.Window:AddCombo("Choose Category")
    categoryPicker.Visible = false
    self.Filter.CategoryPicker = categoryPicker
    
    byMod.OnChange = function()
        if byMod.Checked == true then
            self.Filter.ModPicker.Visible = true
        else
            self.Filter.ModPicker.Visible = false
        end
    end
    byCategory.OnChange = function()
        if byCategory.Checked == true then
            self.Filter.CategoryPicker.Visible = true
        else
            self.Filter.CategoryPicker.Visible = false
        end
    end
    self.Window:AddSeparator("")
    --self:AddAnimationPicker()
    local left = self.Window:AddButton(" <- ")
    local pick = self.Window:AddCombo("")
    local right = self.Window:AddButton(" -> ")
    pick.SameLine = true
    right.SameLine = true
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
        if AnimationName ~= "New" then
            local animRow = self.AnimationsTable.AddRow()
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
                        ID = USERID,
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
    end
    Debug.USEPREFIX = debugbefore

    self:AddWindowSizeTest()
end

local function Unsub(handler)
    handler:Unsubscribe()
end

function WaitForClick()
    local handler = Ext.Events.MouseButtonInput:Subscribe(function (e)
        e:PreventAction()
        if e.Button == 1 and e.Pressed == true then
            if getMouseover() then
                _D(getMouseover())
            end
        end
    end)
end

function SceneControl:AddWindowSizeTest()
    local testbutton = self.Window:AddButton("GetWindowSize")
    local clickedBefore = true
    testbutton.OnClick = function()
        local handler = WaitForClick()
        if clickedBefore == true then
            Unsub(handler)
            clickedBefore = false
        else
            clickedBefore = true
        end
    end
end

-- sending events not secessary as this is accessible on the client
-- UIEvents.FetchFilteredAnimations:SetHandler(function (payload)
--     local filter = payload.filter
--     local animations = getFilteredAnimations(filter)
--     UIEvents:SendFilteredAnimations(animations, payload.ID)
-- end)