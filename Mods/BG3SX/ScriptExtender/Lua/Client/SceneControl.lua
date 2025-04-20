SceneControl = {}
SceneControl.__index = SceneControl
function SceneTab:NewSceneControl(Scene)
    local id = Table.GetNextFreeIndex(self.ActiveSceneControls)  -- this seems wonky. It always increases
    local instance = setmetatable({
        ID = id,
        Scene = Scene, --check if it needs to be updated when scene changes or if this points to the original one
        Window = Ext.IMGUI.NewWindow(id),
        }, SceneControl)
    instance:UpdateWindowName()
    table.insert(self.ActiveSceneControls, instance)
    instance:Initialize()
    return instance
end

function SceneControl:UpdateWindowName()
    local involved = self.Scene.entities
    if involved[1] and type(involved[1]) == "string" then
        -- self.Window.Label = "Window " .. self.ID .. " - Scene: " .. Helper.GetName(involved[1])
        self.Window.Label = Helper.GetName(involved[1])
        if involved[2] then
            if not Helper.StringContainsOne(involved[1],involved[2]) then
                if involved[2] and type(involved[2]) == "string" then
                    -- self.Window.Label = "Window " .. self.ID .. " - Scene: " .. Helper.GetName(involved[1]) .. " + " .. Helper.GetName(involved[2])
                    self.Window.Label = Helper.GetName(involved[1]) .. " + " .. Helper.GetName(involved[2])
                end
            end
        end
    end
end

function UI.DestroyAllSceneControls(backToServer)
    if UIInstance.SceneTab then
        local tab = UIInstance.SceneTab
        if tab.ActiveSceneControls and #tab.ActiveSceneControls > 0 then
            for _,sceneControl in pairs(tab.ActiveSceneControls) do
                sceneControl:Destroy(backToServer)
            end
        end
    end
end
Event.DestroyAllSceneControls:SetHandler(function ()
    UI.DestroyAllSceneControls(false)
end)

function UI.FetchScenes()
    Event.FetchScenes:SendToServer("")
end

-- Resets the SceneControl instance
-- Only the window and SceneControl ID remains
-- Windows currently can't be destroyed so its closed instead
-- On new SceneControl creation, pick up on if there are any empty ones and use these first before creating a new one
function SceneControl:Destroy(backToServer)
    if backToServer then
        Event.StopSex:SendToServer({ID = self.ID, Scene = self.Scene})
    end
    -- for _,SceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
    --     if SceneControl.Instance == self then
    --         SceneControl.Reference:Destroy() -- Delete SceneTab Reference Imgui Element
    --         SceneControl.Reference = nil -- Set to nil for NoSceneText update
    --         UIInstance.SceneTab:UpdateNoSceneText()
    --         Event.RequestSyncActiveScenes:SendToServer()
    --     end
    -- end

    self.Reference:Destroy() -- Delete SceneTab Reference Imgui Element
    self.Reference = nil -- Set to nil for NoSceneText update
    UIInstance.SceneTab:UpdateNoSceneText()
    Event.RequestSyncActiveScenes:SendToServer()

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
    -- self.Window.OnClick = function()
    --     self:SetLastSelected()
    -- end
    self.Window.OnClose = function ()
        self.Window.Open = false
    end

    self.OriginalSize = {330*ViewPortScale, 170*ViewPortScale}
    self.Window:SetSize(self.OriginalSize)
    self:AdjustPositionOnSpawn()
    self.Window:SetStyle("WindowRounding", 10)
    self.Window.Closeable = true
    self.Window.NoResize = true

    self.Animations = {}
    self.AnimationPicker = {}
    self:CreateAnimationControlArea()
    self:CreateSceneTabReference()
end

-- Adjusts the position of the SceneControl window on spawn based on amount of SceneControls already spawned
function SceneControl:AdjustPositionOnSpawn()

    -- Reuse when OnClick works for windows
    -- local baseX = round(ViewPort[1] * 0.5723)
    -- local baseY = round(ViewPort[2] * 0.7361)
    -- baseX = clamp(baseX, 0, ViewPort[1] - self.OriginalSize[1])
    -- baseY = clamp(baseY, 0, ViewPort[2] - self.OriginalSize[2])
    -- self.OriginalPosition = {baseX, baseY}
    
    -- local activeSC = UIInstance.SceneTab.ActiveSceneControls
    -- if #activeSC == 0 then
    --     self.Window:SetPos(self.OriginalPosition)
    -- else
    --     for _,sceneControl in pairs(activeSC) do
    --         if sceneControl.LastSelected then
    --             local posX = clamp(sceneControl.Window.LastPosition[1] + 15, 0, ViewPort[1] - self.OriginalSize[1])
    --             local posY = clamp(sceneControl.Window.LastPosition[2] + 15, 0, ViewPort[2] - self.OriginalSize[2])
    --             self.Window:SetPos({posX, posY})
    --         end
    --     end
    -- end

    local baseX = round(ViewPort[1] * 0.5723)
    local baseY = round(ViewPort[2] * 0.7361)
    baseX = clamp(baseX, 0, ViewPort[1] - self.OriginalSize[1])
    baseY = clamp(baseY, 0, ViewPort[2] - self.OriginalSize[2])
    self.OriginalPosition = {baseX, baseY}
    
    local activeSC = UIInstance.SceneTab.ActiveSceneControls
    local scCount = #activeSC
    local posX = clamp(baseX - 15 + (15 * scCount), 0, ViewPort[1] - self.OriginalSize[1])
    local posY = clamp(baseY - 15 + (15 * scCount), 0, ViewPort[2] - self.OriginalSize[2])
    self.Window:SetPos({posX, posY})
end

function SceneControl:SetLastSelected()
    for _,sceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
        if sceneControl ~= self then
            sceneControl.LastSelected = false
        end
    end
    self.LastSelected = true
end

function SceneControl:ResetPosition()
    self.Window:SetPos(self.OriginalPosition)
end

function SceneControl:CreateSceneTabReference()
    local refGroup = UIInstance.SceneTab.Tab:AddGroup("")
    local popup = refGroup:AddPopup(self.Window.Label)
    local ref = refGroup:AddSelectable(self.Window.Label)
    local openButton = popup:AddSelectable("Open Scene Control")
    local closeButton = popup:AddSelectable("End Scene")
    -- closeButton.SameLine = true
    -- local ref = refGroup:AddText(self.Window.Label)
    -- ref.SameLine = true
    ref.OnClick = function()
        ref.Selected = false
        popup:Open()
    end
    openButton.OnClick = function()
        openButton.Selected = false
        self.Window.Open = true
    end
    closeButton.OnClick = function()
        openButton.Selected = false
        self:Destroy(true)
    end
    -- for _,SceneControl in pairs(UIInstance.SceneTab.ActiveSceneControls) do
    --     if SceneControl.Instance == self then
    --         SceneControl.Reference = refGroup
    --     end
    -- end
    self.Reference = refGroup
end

function SceneControl:AddControlButtons()
    self.ControlButtons = {}
    local buttons = {
        {Name = "Pause/Unpause", Icon = "Spell_Abjuration_ArcaneLock"},
        {Name = "Swap Position", Icon = "BG3SX_ICON_Scene_SwitchPlaces"},
        {Name = "Rotate Scene", Icon = "BG3SX_ICON_Scene_Rotate"},
        --"Change Camera Height",
        {Name = "Move Scene", Icon = "BG3SX_ICON_Scene_Move"},
        {Name = "Stop Sex", Icon = "BG3SX_ICON_Scene_End"},
    }

    for _,button in pairs(buttons) do
        local iconButton = self.Window:AddImageButton(button.Name, button.Icon, {50*ViewPortScale,50*ViewPortScale})
        table.insert(self.ControlButtons, iconButton)
        iconButton.SameLine = true
        iconButton.OnClick = function()
            self:UseSceneControlButton(iconButton.Label)
        end
        iconButton:Tooltip():AddText(iconButton.Label)
    end
end

function SceneControl:UseSceneControlButton(buttonLabel)
    --local UI = UI.GetUIByID(self.UI)
    if buttonLabel == "Pause/Unpause" then
        Event.TogglePause:SendToServer({ID = USERID, Scene = self.Scene})
    elseif buttonLabel == "Swap Position" then
        Event.SwapPosition:SendToServer({ID = USERID, Scene = self.Scene})
    elseif buttonLabel == "Rotate Scene" then
        UIInstance:AwaitInput("RotateScene", self.Scene)
    elseif buttonLabel == "Change Camera Height" then
        Event.ChangeCameraHeight:SendToServer({ID = USERID})
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
    Event.FetchAllAnimations:SendToServer({ID = USERID, SceneControl = self.ID})
end

function SceneControl:UpdateAnimationData(animationData)
    self.Animations = animationData
    self:UpdateAnimationPicker()
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

    local sortedMods = {}
    if mods and #mods > 0 then
        sortedMods = Table.SortByKeys(mods)
    end
    return sortedMods
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
                    -- Debug.Print(AnimationName .. " does not have a category assigned")
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
                    -- Debug.Print("Category ".. category)
                    if Animation.Enabled and category == filter then
                        validAnimations[AnimationName] = Animation
                    end
                end

            else
                -- Debug.Print(Animation.Name .. " does not have a category assigned")
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
    local sep = g:AddSeparator("")
    sep:SetStyle("SeparatorTextPadding", 5)

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
                if not animsByType[moduleUUID] then
                    animsByType[moduleUUID] = {}
                end
                if (type == "SoloP") or (type == "SoloV") then
                    local matchT = hmi.matchingTable
                    if matchT and #matchT > 0 then
                        for _,matchup in pairs(matchT) do
                            if matchup.Solo then
                                if Table.Contains(AnimationData.Categories, type) then
                                    animsByType[moduleUUID][AnimationName] = AnimationData
                                end
                            end
                        end
                    end
                elseif (type == "Lesbian") or (type == "Straight") or (type == "Gay") then
                    if hmi.fallbackTop and hmi.fallbackBottom then
                        if Table.Contains(AnimationData.Categories, type) then
                            animsByType[moduleUUID][AnimationName] = AnimationData
                        else
                            if UIInstance.SettingsTab.UnlockedAnimations.Checked == true then
                                animsByType[moduleUUID][AnimationName] = AnimationData
                            end
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
                _P(AnimationName .. " already exists, adding a number to the name")
                _P("By mod " .. moduleUUID)
                sameNameCounter = sameNameCounter + 1
                pickerEntries[AnimationName .. " " .. sameNameCounter] = {moduleUUID = moduleUUID, AnimationData = AnimationData}
            else
                pickerEntries[AnimationName] = {moduleUUID = moduleUUID, AnimationData = AnimationData}
            end
        end
    end

    return pickerEntries
end

function SceneControl:UpdateAuthor(holder, animData)
    if not animData then
        holder.Label = "Select an Animation"
    end
    local actualAuthor = Helper.GetModAuthor(animData.Mod)
    if actualAuthor == "Lune, Skiz, Satan" then
        actualAuthor = "Lune"
    end
    holder.Label = "By: " .. actualAuthor
    holder.Visible = true
end


function SceneControl:HidePicker()
    self.AnimationPicker.Group.Visible = false
end

function SceneControl:ShowPicker()
    self.AnimationPicker.Group.Visible = true
end

function SceneControl:GetUpdatedPickerAnims()
    local animsByType = self:GetAnimationsBySceneType()
    local animPickerAnims = self:ConvertAnimationsForPicker(animsByType)
    return animPickerAnims
end

function SceneControl:UpdateAnimationPicker()
    local debugbefore = Debug.USEPREFIX
    Debug.USEPREFIX = false

    -- Create before to use within local functions
    local authorName
    local animationPicker

    local function updatePickerOptions(picker)
        local animPickerAnims = self:GetUpdatedPickerAnims()
        picker.UserData = animPickerAnims

        local animNames = {}
        for AnimName,Data in pairs(picker.UserData) do
            table.insert(animNames, AnimName)
        end
        table.sort(animNames)
        picker.Options = {}
        picker.Options = animNames
    end

    local function buildPicker()
        self.AnimationPicker.Group = self.Window:AddGroup("")
        local g = self.AnimationPicker.Group

        local function updateIndex(delta)
            local total = #animationPicker.Options
            local current = animationPicker.SelectedIndex
            local newIndex = ((current >= 0 and current or 0) + delta) % total
            animationPicker.SelectedIndex = newIndex
        end

        local function newPick()
            local indexData = animationPicker.Options[animationPicker.SelectedIndex+1] -- SelectedIndex begins with 0 but table starts with 1 so we increase by 1
            local moduleUUID = animationPicker.UserData[indexData].moduleUUID
            local animData = animationPicker.UserData[indexData].AnimationData
            if animData then
                Event.ChangeAnimation:SendToServer({
                    ID = USERID,
                    Caster = self.Scene.entities[1],
                    -- moduleUUID = moduleUUID,
                    AnimationData = animData,
                })
            end
            self:UpdateAuthor(authorName, animData)
        end

        local previousButton = g:AddButton("<-")
        previousButton.OnClick = function()
            updateIndex(-1)
            newPick()
        end

        animationPicker = g:AddCombo("")
        updatePickerOptions(animationPicker)
        animationPicker.SelectedIndex = -1
        animationPicker.OnChange = function ()
            newPick()
        end
        animationPicker.SameLine = true

        local nextButton = g:AddButton("->")
        nextButton.OnClick = function()
            updateIndex(1)
            newPick()
        end
        nextButton.SameLine = true

        authorName = g:AddText("Select an Animation")

        local indexData = animationPicker.Options[animationPicker.SelectedIndex+1] -- SelectedIndex begins with 0 but table starts with 1 so we increase by 1
        if indexData ~= nil then
            local moduleUUID = animationPicker.UserData[indexData].moduleUUID
            local animData = animationPicker.UserData[indexData].AnimationData
            local actualAuthor = Helper.GetModAuthor(animData.Mod)
            if actualAuthor then
                self:UpdateAuthor(authorName, animData)
            else
                authorName.Visible = false -- Keep invisible initially
            end
        end

        if #animationPicker.Options == 0 then
            self:HidePicker()
        else
            self:ShowPicker()
        end

        self.AnimationPicker.Previous = previousButton
        self.AnimationPicker.AnimationPicker = animationPicker
        self.AnimationPicker.Next = nextButton
        self.AnimationPicker.Author = authorName
    end

    if self.AnimationPicker and self.AnimationPicker.Group then
        updatePickerOptions(self.AnimationPicker.AnimationPicker)
        self:UpdateAuthor(self.AnimationPicker.Author)
        if self.AnimationPicker.AnimationPicker.Options == 0 then
            self:HidePicker()
        else
            self:ShowPicker()
        end
    else
        if self.AnimationPicker then
            if not self.AnimationPicker.Group then
                buildPicker()
            end
        end
    end

    Debug.USEPREFIX = debugbefore
end

-- function SceneControl:AddMoveControl()
--     self.Transform = {}
--     self.Transform.Transform = {}
--     self.Transform.Rotation = {}

--     local sliderX = parent:AddSlider("Forward/Back", 0, -100, 100)
--     Style.Sliders.SliderDefault(sliderX)
--     sliderX.OnChange = function(value)
--         local currentValue = tonumber(value.Value[1])
--         if currentValue and currentValue ~= 0 then
--             MainPostToServer.MoveCharacter(0, 0, currentValue * 0.001)
--             sliderX.Value = {0, 0, 0, 0}
--         end
--     end

--     local sliderY = parent:AddSlider("Left/Right", 0, -100, 100)
--     Style.Sliders.SliderDefault(sliderY)
--     sliderY.OnChange = function(value)
--         local currentValue = tonumber(value.Value[1])
--         if currentValue and currentValue ~= 0 then
--             MainPostToServer.MoveCharacter(currentValue * 0.001, 0, 0)
--             sliderY.Value = {0, 0, 0, 0}
--         end
--     end

--     local sliderZ = parent:AddSlider("Up/Down", 0, -100, 100)
--     Style.Sliders.SliderDefault(sliderZ)
--     sliderZ.OnChange = function(value)
--         local currentValue = tonumber(value.Value[1])
--         if currentValue and currentValue ~= 0 then
--             MainPostToServer.MoveCharacter(0, currentValue * 0.001, 0)
--             sliderZ.Value = {0, 0, 0, 0}
--         end
--     end

-- end