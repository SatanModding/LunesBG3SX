SceneControl = {}
SceneControl.__index = SceneControl
SceneControl.ActiveSceneControls = {}
function SceneControl:Init()
    if UI.SceneTab then
        local instance = setmetatable({
            ActiveSceneControls = {},
            }, SceneControl)
        return instance
    end
end

function SceneControl:CreateInstance(Scene)
    if UI.SceneTab then
        local instance = SceneControlInstance:New(Scene)
        table.insert(self.ActiveSceneControls, instance)
        return instance
    end
end

-- Goes through every currently running scene until it finds the entityToSearch
---@param entityToSearch string
function SceneControl:FindInstanceByEntity(entityToSearch)
    for _,instance in pairs(self.ActiveSceneControls) do
        for _, entity in pairs(instance.Scene.entities) do
            if Helper.StringContainsOne(entityToSearch, entity) then
                _P("Found scene control for entity: ", entityToSearch)
                return instance
            end
        end
    end
end

---@class SceneControlInstance
---@field ID number
---@field Scene Scene
---@field Window ExtuiWindow
---@field Reference ExtuiGroup
---@field private OriginalSize vec2
---@field private OriginalPosition vec2
---@field LastSelected boolean
---@field Animations table
---@field AnimationPicker table
---@field ControlButtons table

SceneControlInstance = {}
SceneControlInstance.__index = SceneControlInstance
function SceneControlInstance:New(Scene)
    local id = Table.GetNextFreeIndex(SceneControl.ActiveSceneControls)  -- this seems wonky. It always increases
    local instance = setmetatable({
        ID = id,
        Scene = Scene, --check if it needs to be updated when scene changes or if this points to the original one
        Window = Ext.IMGUI.NewWindow(id),
        }, SceneControlInstance)
    instance:UpdateWindowName()
    table.insert(SceneControl.ActiveSceneControls, instance)
    instance:Initialize()
    return instance
end

function SceneControlInstance:UpdateWindowName()
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

-- Resets the SceneControl instance
-- Only the window and SceneControl ID remains
-- Windows currently can't be destroyed so its closed instead
-- On new SceneControl creation, pick up on if there are any empty ones and use these first before creating a new one
function SceneControlInstance:Destroy(backToServer)
    if backToServer then
        Event.StopSex:SendToServer({Scene = self.Scene})
    end
    -- for _,SceneControl in pairs(UI.SceneControl.ActiveSceneControls) do
    --     if SceneControl.Instance == self then
    --         SceneControl.Reference:Destroy() -- Delete SceneTab Reference Imgui Element
    --         SceneControl.Reference = nil -- Set to nil for NoSceneText update
    --         UI.SceneTab:UpdateNoSceneText()
    --         Event.RequestSyncActiveScenes:SendToServer()
    --     end
    -- end

    self.Reference:Destroy() -- Delete SceneTab Reference Imgui Element
    self.Reference = nil -- Set to nil for NoSceneText update
    UI.SceneTab:UpdateNoSceneText()
    -- Event.RequestSyncActiveScenes:SendToServer()

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
    Table.RemoveByValue(UI.SceneControl.ActiveSceneControls, self)
    self = nil
end

function SceneControlInstance:Initialize()
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
function SceneControlInstance:AdjustPositionOnSpawn()

    -- Reuse when OnClick works for windows
    -- local baseX = round(ViewPort[1] * 0.5723)
    -- local baseY = round(ViewPort[2] * 0.7361)
    -- baseX = clamp(baseX, 0, ViewPort[1] - self.OriginalSize[1])
    -- baseY = clamp(baseY, 0, ViewPort[2] - self.OriginalSize[2])
    -- self.OriginalPosition = {baseX, baseY}
    
    -- local activeSC = UI.SceneControl.ActiveSceneControls
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
    
    local activeSC = UI.SceneControl.ActiveSceneControls
    local scCount = #activeSC
    local posX = clamp(baseX - 15 + (15 * scCount), 0, ViewPort[1] - self.OriginalSize[1])
    local posY = clamp(baseY - 15 + (15 * scCount), 0, ViewPort[2] - self.OriginalSize[2])
    self.Window:SetPos({posX, posY})
end

function SceneControlInstance:SetLastSelected()
    for _,sceneControl in pairs(UI.SceneControl.ActiveSceneControls) do
        if sceneControl ~= self then
            sceneControl.LastSelected = false
        end
    end
    self.LastSelected = true
end

function SceneControlInstance:ResetPosition()
    self.Window:SetPos(self.OriginalPosition)
end

function SceneControlInstance:CreateSceneTabReference()
    UI.SceneTab.ActiveScenesSeparator.Visible = true
    local refGroup = UI.SceneTab.Tab:AddGroup("")
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
    -- for _,SceneControl in pairs(UI.SceneControl.ActiveSceneControls) do
    --     if SceneControl.Instance == self then
    --         SceneControl.Reference = refGroup
    --     end
    -- end
    self.Reference = refGroup
end

function SceneControlInstance:AddControlButtons()
    self.ControlButtons = {}
    local buttons = {
        {Name = "Pause", Icon = "BG3SX_PauseScene_Dormant"},
        {Name = "Unpause", Icon = "BG3SX_PauseScene_Active", Visible = false}, -- Unpause is only visible when paused
        {Name = "Swap Position", Icon = "BG3SX_ICON_Scene_SwitchPlaces"},
        {Name = "Rotate Scene", Icon = "BG3SX_ICON_Scene_Rotate"},
        --"Change Camera Height",
        {Name = "Move Scene", Icon = "BG3SX_ICON_Scene_Move"},
        {Name = "End Scene", Icon = "BG3SX_StopSceneNew"},
    }

    for _,button in pairs(buttons) do
        local iconButton = self.Window:AddImageButton(button.Name, button.Icon, {50*ViewPortScale,50*ViewPortScale})
        table.insert(self.ControlButtons, iconButton)
        iconButton.SameLine = true
        iconButton.OnClick = function()
            self:AddButtonFunctionality(iconButton.Label)
        end
        iconButton:Tooltip():AddText(iconButton.Label)
    end
end

function SceneControlInstance:AddButtonFunctionality(buttonLabel)
    --local UI = UI.GetUIByID(self.UI)
    if buttonLabel == "Pause" then
        Event.TogglePause:SendToServer({ID = USERID, Scene = self.Scene})
        self:HideButton("Pause")
        self:ShowButton("Unpause")
    elseif buttonLabel == "Unpause" then
        Event.TogglePause:SendToServer({ID = USERID, Scene = self.Scene})
        self:HideButton("Unpause")
        self:ShowButton("Pause")
    elseif buttonLabel == "Swap Position" then
        Event.SwapPosition:SendToServer({ID = USERID, Scene = self.Scene})
    elseif buttonLabel == "Rotate Scene" then
        UI:AwaitInput("RotateScene", self.Scene)
    elseif buttonLabel == "Change Camera Height" then
        Event.ChangeCameraHeight:SendToServer({ID = USERID})
    elseif buttonLabel == "Move Scene" then
        UI:AwaitInput("MoveScene", self.Scene)
    elseif buttonLabel == "End Scene" then
        self:Destroy(true)
    end
end

-- Creates some initial buttons with their own events
-- Sends an Event to Server, requesting Animations 
function SceneControlInstance:CreateAnimationControlArea()
    self:AddControlButtons()
    Event.FetchAllAnimations:SendToServer({ID = USERID, SceneControl = self.ID})
end

function SceneControlInstance:UpdateAnimationData(animationData)
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

function SceneControlInstance:FilterAnimationsByCategory(filter)
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

function SceneControlInstance:FilterAnimationsByMod(filter)
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


function SceneControlInstance:GetFilteredAnimations(modFilter, animationFilter)
    local tbl1 = self:FilterAnimationsByMod(modFilter)
    local tbl2 = self:FilterAnimationsByCategory(animationFilter)

    return Table.GetIntersection(tbl1, tbl2)
end

function SceneControlInstance:CreateFilters()
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

function SceneControlInstance:GetAnimationsBySceneType()
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
                            if UI.Settings["UnlockedAnimations"] then
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

function SceneControlInstance:ConvertAnimationsForPicker(animsByType)
    local pickerEntries = {}
    for moduleUUID,Anims in pairs(animsByType) do
        local sameNameCounter = 1
        for AnimationName,AnimationData in pairs(Anims) do
            if pickerEntries[AnimationName] then
                sameNameCounter = sameNameCounter + 1
                _P(AnimationName .. " already exists, it will be called " .. AnimationName .. " " .. sameNameCounter)
                _P("By mod " .. Ext.Mod.GetMod(moduleUUID).Info.Name)
                pickerEntries[AnimationName .. " " .. sameNameCounter] = {moduleUUID = moduleUUID, AnimationData = AnimationData}
            else
                pickerEntries[AnimationName] = {moduleUUID = moduleUUID, AnimationData = AnimationData}
            end
        end
    end

    return pickerEntries
end

function SceneControlInstance:UpdateAuthor(holder, animData)
    if not animData then
        holder.Label = "Select an Animation"
    else
        local actualAuthor = Helper.GetModAuthor(animData.Mod)
        if actualAuthor == "Lune, Skiz, Satan" then
            actualAuthor = "Lune"
        end
        holder.Label = "By: " .. actualAuthor
    end
    holder.Visible = true
end


function SceneControlInstance:HidePicker()
    self.AnimationPicker.Group.Visible = false
end

function SceneControlInstance:ShowPicker()
    self.AnimationPicker.Group.Visible = true
end

function SceneControlInstance:GetUpdatedPickerAnims()
    local animsByType = self:GetAnimationsBySceneType()
    local animPickerAnims = self:ConvertAnimationsForPicker(animsByType)
    return animPickerAnims
end

function SceneControlInstance:UpdateAnimationPicker()
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

return SceneControl, SceneControlInstance