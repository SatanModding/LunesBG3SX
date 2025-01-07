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

    -- if UIInstance.Settings.ShowAllAnimations == true then
    --     UIEvents.FetchAllAnimations:SendToServer({ID = USERID, SceneControl = self.ID, Caster = _C().Uuid.EntityUuid})
    -- elseif UIInstance.Settings.ShowAllAnimations == false then
    --     UIEvents.FetchFilteredAnimations:SendToServer({ID = USERID, SceneControl = self.ID, Caster = _C().Uuid.EntityUuid})
    -- end

    Debug.Print("----------------FETCHANIMATIONS")
    UIEvents.FetchAllAnimations:SendToServer({ID = _C().Uuid.EntityUuid, SceneControl = self.ID})

    --self:CreateFilters()

    --self:AddAnimationPicker()
    -- local left = self.Window:AddButton(" <- ")
    -- local pick = self.Window:AddCombo("")
    -- local right = self.Window:AddButton(" -> ")
    -- pick.SameLine = true
    -- right.SameLine = true
    
end

function SceneControl:UpdateAnimationData(animationData)
    Debug.Print("Test+")
    self.Animations = animationData
    table.sort(self.Animations)
    self:CreateFilters()
    self:AddAnimationPicker()
end



local function getAllMods(animationData)

    local mods = {}


    for AnimationName,Animation in pairs(animationData) do
        if not (AnimationName == "New") then

            local modName = Animation.Mod
            if Animation.Enabled then
                mods[modName] = true
            end
        end
    end

    return mods
end



local function getAllCategories(animationData)

local categories = {}

    for AnimationName,Animation in pairs(animationData) do
        if not (AnimationName == "New") then

            local categories = Animation.Categories

            if categories then
        
                for _,category in pairs(categories) do
                    if Animation.Enabled then
                        categories[category] = true
                    end
                end
            else
                Debug.Print(Animation.Name .. " does not have a category assigned")
            end
        end
    end

    return categories

end

function SceneControl:FilterAnimationsByCategory(filter)
    filter = filter or nil

    local animations = {}

    if not filter then
        return self.Animations
    end

    for AnimationName,Animation in pairs(self.Animations) do
        print(AnimationName)
        if not (AnimationName == "New") then

            local categories = Animation.Categories

            if categories then

                for _,category in pairs(categories) do
                    Debug.Print("Category ".. category)
                    if Animation.Enabled and category == filter then
                        animations[AnimationName] = Animation
                    end
                end

            else
                Debug.Print(Animation.Name .. " does not have a category assigned")
            end
        end
    end

    return animations
end

function SceneControl:FilterAnimationsByMod(filter)
    filter = filter or nil

    local animations = {}

    if not filter then
        return self.Animations
    end

    for AnimationName,Animation in pairs(self.Animations) do
        print(AnimationName)
        if not (AnimationName == "New") then
            if Animation.Enabled and Animation.Mod == filter then
                
                animations[AnimationName] = Animation
            end
        end
    end

    return animations
end


function SceneControl:GetFilteredAnimations(modFilter, animationFilter)
    tbl1 = self:FilterAnimationsByMod(modFilter)
    tbl2 = self:FilterAnimationsByCategory(animationFilter)
    
    return Table.GetIntersection(tbl1, tbl2)
end

function SceneControl:CreateFilters()
    if self.Filter and #self.Filter >0 and self.Filter.Group then
        UI.DestroyChildren(self.Filter.Group)
        self.Filter = nil
        if self.Filter and #self.Filter >0 then -- Sanity Check
            for _,elem in pairs(self.Filter) do
                UI.DestroyChildren(elem)
            end
        end
    end

    self.Filter = {}
    self.Filter.Group = self.Window:AddGroup("")
    local g = self.Filter.Group
    g:AddSeparator("")

    -- Filter Area
    self.Filter = {}
    local byMod = g:AddCheckbox("Filter by Mod")
    byMod.Checked = false
    self.Filter.Mod = byMod
    
    local byCategory = g:AddCheckbox("Filter by Category")
    byCategory.Checked = false
    byCategory.SameLine = true
    self.Filter.Category = byCategory

    local modPicker = g:AddCombo("Choose Mod")
    modPicker.Visible = false
    self.Filter.ModPicker = modPicker

    local catPicker = g:AddCombo("Choose Category")
    catPicker.Visible = false
    self.Filter.CategoryPicker = catPicker
    
    byMod.OnChange = function()
        if byMod.Checked == true then
            modPicker.Visible = true
            modPicker.OnChange = function()
                local modSelection = modPicker.Options[modPicker.SelectedIndex+1]
                local catSelection = catPicker.Options[catPicker.SelectedIndex+1]
                self:GetFilteredAnimations(modSelection, catSelection)
            end
        else
            modPicker.Visible = false
            modPicker.SelectedIndex = 0
        end
    end
    byCategory.OnChange = function()
        if byCategory.Checked == true then
            catPicker.Visible = true
            local modSelection = modPicker.Options[modPicker.SelectedIndex+1]
            local catSelection = catPicker.Options[catPicker.SelectedIndex+1]
            self:GetFilteredAnimations(modSelection, catSelection)
        else
            catPicker.Visible = false
            catPicker.SelectedIndex = 0
        end
    end

    getAllMods(self.Animations)
    getAllCategories(self.Animations)
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

function SceneControl:GetAnimationsBySceneType()
    local type = self.Scene.SceneType
    local animsByType = {}
    for AnimationName,AnimationData in pairs(self.Animations) do
        if AnimationData.Enabled == true then
            local hmi = AnimationData.Heightmatching
            if (type == "SoloP") or (type == "SoloV") then
                local matchT = hmi.matchingTable
                if matchT and #matchT > 0 then
                    for _,matchup in pairs(matchT) do
                        if matchup.Solo then
                            if not Table.Contains(animsByType, AnimationName) then
                                if type == "SoloP" and Table.Contains(AnimationData.Categories, type) then
                                    table.insert(animsByType, AnimationName)
                                elseif type == "SoloV" and Table.Contains(AnimationData.Categories, type) then
                                    table.insert(animsByType, AnimationName)
                                end
                            end
                        end
                    end
                end
            elseif (type == "Lesbian") or (type == "Straight") or (type == "Gay") then
                if hmi.fallbackTop and hmi.fallbackBottom then
                    if not Table.Contains(animsByType, AnimationName) then
                        if type == "Lesbian" and Table.Contains(AnimationData.Categories, type) then
                            table.insert(animsByType, AnimationName)
                        elseif type == "Straight" and Table.Contains(AnimationData.Categories, type) then
                            table.insert(animsByType, AnimationName)
                        elseif type == "Gay" and Table.Contains(AnimationData.Categories, type) then
                            table.insert(animsByType, AnimationName)
                        end
                    end
                end
            end
        end
    end
    return animsByType
end

function SceneControl:AddAnimationPicker()
    local debugbefore = Debug.USEPREFIX
    Debug.USEPREFIX = false
    
    Debug.Print("SceneControl Animations")
    Debug.DumpS(self.Animations)

    if self.AnimationPicker and #self.AnimationPicker >0 and self.AnimationPicker.Group then
        UI.DestroyChildren(self.AnimationPicker.Group)
        self.AnimationPicker = nil
        if self.AnimationPicker and #self.AnimationPicker >0 then -- Sanity Check
            for _,elem in pairs(self.AnimationPicker) do
                UI.DestroyChildren(elem)
            end
        end
    end

    self.AnimationPicker.Group = self.Window:AddGroup("")
    local g = self.AnimationPicker.Group
    g:AddSeparator("")

    local animationPicker -- Create before to use within previousButton.OnClick function
    local previousButton = g:AddButton("<-")
    previousButton.OnClick = function()
        updateCombo(animationPicker, -1)
    end
    previousButton.SameLine = true

    local anims = self:GetAnimationsBySceneType()
    animationPicker = g:AddCombo("")
    animationPicker.Options = anims -- Will get overwritten by filters
    animationPicker.SelectedIndex = 1
    animationPicker.OnChange = function ()
        if animationPicker.SelectedIndex ~= 0 then
            UIEvents.ChangeAnimation:SendToServer({
                ID = USERID,
                Caster = _C().Uuid.EntityUuid,
                Animation = animationPicker.Options[animationPicker.SelectedIndex]
            })
        end
    end
    animationPicker.SameLine = true

    local nextButton = g:AddButton("->")
    nextButton.OnClick = function()
        updateCombo(animationPicker, 1)
    end
    nextButton.SameLine = true

    local authorName = g:AddText("By: NAN")

    self.AnimationPicker.Previous = previousButton
    self.AnimationPicker.AnimationPicker = animationPicker
    self.AnimationPicker.Next = nextButton
    self.AnimationPicker.Author = authorName

    Debug.USEPREFIX = debugbefore
end