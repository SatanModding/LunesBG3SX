SceneControl = {}
SceneControl.__index = SceneControl
function SceneTab:NewSceneControl(Scene)
    -- Check if there are any viable leftover SceneControl instances
    -- if self.ActiveSceneControls and #self.ActiveSceneControls > 0 then
    --     for _,sceneControl in pairs(self.ActiveSceneControls) do
    --         if sceneControl.Unused then
    --             sceneControl.Scene = Scene
    --             sceneControl.Window.Open = true
    --             sceneControl:UpdateWindowName()
    --             sceneControl:Initialize()
    --             sceneControl.Unused = nil
    --             return sceneControl
    --         end
    --     end
    -- end
    -- If no viable leftover was found, create a new one
    --_DS(self.ActiveSceneControls)
    --_P("ActiveSceneControls " .. #self.ActiveSceneControls)
    local id = Table.GetNextFreeIndex(self.ActiveSceneControls)  -- this seems wonky. It always increases
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
        -- self.Window.Label = "Window " .. self.ID .. " - Scene: " .. Helper.GetName(involved[1])
        self.Window.Label = "Scene: " .. Helper.GetName(involved[1])
        if not Helper.StringsContainOne(involved[1],involved[2]) then
            if involved[2] and type(involved[2]) == "string" then
                -- self.Window.Label = "Window " .. self.ID .. " - Scene: " .. Helper.GetName(involved[1]) .. " + " .. Helper.GetName(involved[2])
                self.Window.Label = "Scene: " .. Helper.GetName(involved[1]) .. " + " .. Helper.GetName(involved[2])
            end
        end
    end
end

function UI.DestroyAllSceneControls(backToServer)
    if UIInstance.SceneTab then
        local tab = UIInstance.SceneTab
        if tab.ActiveSceneControls and #tab.ActiveSceneControls > 0 then
            for _,sceneControl in pairs(tab.ActiveSceneControls) do
                sceneControl.Instance:Destroy(backToServer)
            end
        end
    end
end
UIEvents.DestroyAllSceneControls:SetHandler(function ()
    UI.DestroyAllSceneControls(false)
end)

function UI.FetchScenes()
    UIEvents.FetchScenes:SendToServer("")
end

-- Resets the SceneControl instance
-- Only the window and SceneControl ID remains
-- Windows currently can't be destroyed so its closed instead
-- On new SceneControl creation, pick up on if there are any empty ones and use these first before creating a new one
function SceneControl:Destroy(backToServer)
    if backToServer then
        UIEvents.StopSex:SendToServer({ID = self.ID, Scene = self.Scene})
    end
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
            -- UI.DestroyChildren(self.Window)
            -- self.Window.Open = false
            self.Window:Destroy()
        end
    end
    -- self.Unused = true
    self = nil
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
    local sep = refGroup:AddSeparatorText(self.Window.Label)
    local openButton = refGroup:AddButton("Open Scene Control")
    local closeButton = refGroup:AddButton("End Scene")
    closeButton.SameLine = true
    -- local ref = refGroup:AddText(self.Window.Label)
    -- ref.SameLine = true
    openButton.OnClick = function()
        self.Window.Open = true
    end
    closeButton.OnClick = function()
        self:Destroy(true)
    end
    for _,SceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
        if SceneControl.Instance == self then
            SceneControl.Reference = refGroup
        end
    end
end

function SceneControl:AddControlButtons()
    local buttons = {
        {Name = "Swap Position", Icon = "BG3SX_ICON_Scene_SwitchPlaces"},
        {Name = "Rotate Scene", Icon = "BG3SX_ICON_Scene_Rotate"},
        --"Change Camera Height",
        {Name = "Move Scene", Icon = "BG3SX_ICON_Scene_Move"},
        {Name = "Stop Sex", Icon = "BG3SX_ICON_Scene_End"},
    }

    for _,button in pairs(buttons) do
        local iconButton = self.Window:AddImageButton(button.Name, button.Icon, {50,50})
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
        self:Destroy(true)
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

    -- Debug.Print("----------------FETCHANIMATIONS")
    UIEvents.FetchAllAnimations:SendToServer({ID = USERID, SceneControl = self.ID})

    --self:CreateFilters()

    --self:AddAnimationPicker()
    -- local left = self.Window:AddButton(" <- ")
    -- local pick = self.Window:AddCombo("")
    -- local right = self.Window:AddButton(" -> ")
    -- pick.SameLine = true
    -- right.SameLine = true
    
end

function SceneControl:UpdateAnimationData(animationData)
    -- Debug.Print("Test+")
    self.Animations = animationData
    table.sort(self.Animations)
    -- self:CreateFilters() -- Fix
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



local function getAllCategories(allAnims)
    local allCategories = {}

    for moduleUUID,animations in pairs(allAnims) do
        for AnimationName,AnimationData in pairs(animations) do
            if not (AnimationName == "New") then

                local categories = AnimationData.Categories

                if categories then
            
                    for _,category in pairs(categories) do
                        if AnimationData.Enabled then
                            allCategories[category] = true
                        end
                    end
                else
                    Debug.Print(AnimationName .. " does not have a category assigned")
                end
            end
        end
    end

    return allCategories
end

function SceneControl:FilterAnimationsByCategory(filter)
    filter = filter or nil

    local validAnimations = {}

    if not filter then
        return self.Animations
    end

for modUUID,animations in pairs(self.Animations) do
    for AnimationName,Animation in pairs(animations) do
        -- print(AnimationName)
        if not (AnimationName == "New") then

            local categories = Animation.Categories

            if categories then

                for _,category in pairs(categories) do
                    Debug.Print("Category ".. category)
                    if Animation.Enabled and category == filter then
                        validAnimations[AnimationName] = Animation
                    end
                end

            else
                Debug.Print(Animation.Name .. " does not have a category assigned")
            end
        end
    end
end

    return validAnimations
end

function SceneControl:FilterAnimationsByMod(filter)
    filter = filter or nil

    local validAnimations = {}

    if not filter then
        return self.Animations
    end

    for moduleUUID,animations in pairs(self.Animations) do
        for AnimationName,Animation in pairs(animations) do
            -- print(AnimationName)
            if not (AnimationName == "New") then
                if Animation.Enabled and moduleUUID == filter then
                    
                    validAnimations[AnimationName] = Animation
                end
            end
        end
    end

    return validAnimations
end


function SceneControl:GetFilteredAnimations(modFilter, animationFilter)
    local tbl1 = self:FilterAnimationsByMod(modFilter)
    local tbl2 = self:FilterAnimationsByCategory(animationFilter)
    
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
    local newIndex = combo.SelectedIndex
    newIndex = newIndex + val
    if newIndex < 1 then
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
    for moduleUUID,Anims in pairs(self.Animations) do
        for AnimationName,AnimationData in pairs(Anims) do
            if AnimationData.Enabled == true then
                local hmi = AnimationData.Heightmatching
                if (type == "SoloP") or (type == "SoloV") then
                    local matchT = hmi.matchingTable
                    if matchT and #matchT > 0 then
                        for _,matchup in pairs(matchT) do
                            if matchup.Solo then
                                if not animsByType[moduleUUID] then
                                    animsByType[moduleUUID] = {}
                                end
                                if type == "SoloP" and Table.Contains(AnimationData.Categories, type) then
                                    animsByType[moduleUUID][AnimationName] = AnimationData
                                elseif type == "SoloV" and Table.Contains(AnimationData.Categories, type) then
                                    animsByType[moduleUUID][AnimationName] = AnimationData
                                end
                            end
                        end
                    end
                elseif (type == "Lesbian") or (type == "Straight") or (type == "Gay") then
                    if hmi.fallbackTop and hmi.fallbackBottom then
                        if not animsByType[moduleUUID] then
                            animsByType[moduleUUID] = {}
                        end
                        if type == "Lesbian" and Table.Contains(AnimationData.Categories, type) then
                            animsByType[moduleUUID][AnimationName] = AnimationData
                        elseif type == "Straight" and Table.Contains(AnimationData.Categories, type) then

                            _DS(AnimationData.Name)
                            animsByType[moduleUUID][AnimationName] = AnimationData
                        elseif type == "Gay" and Table.Contains(AnimationData.Categories, type) then
                            animsByType[moduleUUID][AnimationName] = AnimationData
                        end
                    end
                end
            end
        end
    end
    return animsByType
end

function SceneControl:ConvertAnimationsForPicker(animsByType)
    local pickerEntries = {}
    for moduleUUID,Anims in pairs(animsByType) do
        local sameNameCounter = 1
        for AnimationName,AnimationData in pairs(Anims) do
            if pickerEntries[AnimationName] then
                sameNameCounter = sameNameCounter + 1
                pickerEntries[AnimationName .. " " .. sameNameCounter] = {moduleUUID = moduleUUID, AnimationData = AnimationData}
            end
            pickerEntries[AnimationName] = {moduleUUID = moduleUUID, AnimationData = AnimationData}
        end
    end

    return pickerEntries
end


function SceneControl:AddAnimationPicker()
    local debugbefore = Debug.USEPREFIX
    Debug.USEPREFIX = false
    
    -- Debug.Print("SceneControl Animations")
    --Debug.DumpS(self.Animations)

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
        authorName.Visible = true
    end
    previousButton.SameLine = true

    local authorName
    local animsByType = self:GetAnimationsBySceneType()
    local animPickerAnims = self:ConvertAnimationsForPicker(animsByType)
    -- Debug.Print("AnimPickerAnims")
    --S(animPickerAnims) 
    animationPicker = g:AddCombo("")
    animationPicker.UserData = animPickerAnims
    local animNames = {}
    for AnimName,Data in pairs(animationPicker.UserData) do
        table.insert(animNames, AnimName)
    end
    animationPicker.Options = animNames -- Will get overwritten by filters
    -- animationPicker.SelectedIndex = 1
    local newIndex
    animationPicker.OnChange = function ()
        -- _P(animationPicker.SelectedIndex)
        local pick = animationPicker.UserData[animationPicker.Options[animationPicker.SelectedIndex]]
        UIEvents.ChangeAnimation:SendToServer({
            ID = USERID,
            Caster = self.Scene.entities[1],
            moduleUUID = pick.moduleUUID,
            AnimationData = pick.AnimationData,
        })
        -- Debug.Dump(pick.AnimationData)
        local actualAuthor = Helper.GetModAuthor(pick.moduleUUID)
        if actualAuthor == "Lune, Skiz, Satan" then
            actualAuthor = "Lune"
        end
        authorName.Label = "By: " .. actualAuthor
        authorName.Visible = true
    end
    animationPicker.SameLine = true

    local nextButton = g:AddButton("->")
    nextButton.OnClick = function()
        updateCombo(animationPicker, 1)
        authorName.Visible = true
    end
    nextButton.SameLine = true

    authorName = g:AddText("By: NAN")
    authorName.Visible = false -- Keep invisible initially

    self.AnimationPicker.Previous = previousButton
    self.AnimationPicker.AnimationPicker = animationPicker
    self.AnimationPicker.Next = nextButton
    self.AnimationPicker.Author = authorName

    Debug.USEPREFIX = debugbefore
end