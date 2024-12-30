
DebugTab = {}
DebugTab.__index = DebugTab
function UI:NewDebugTab()
    local instance = setmetatable({
        Tab = self.TabBar:AddTabItem("Debug")
    }, DebugTab)
    return instance
end


function DebugTab:Initialize()
    local customEventButton = self.Tab:AddButton("Custom Event")
    customEventButton.OnClick = function()
        UIEvents.CustomEvent:SendToServer("")
    end
    --self.Animations = {} 
    --self.AnimationPickers = {}
    --UI.GetAnimations()
    self:NewLog()
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

function DebugTab:AddAnimationPicker()
    local debugbefore = Debug.USEPREFIX
    Debug.USEPREFIX = false
    table.sort(self.Animations)
    UI.DestroyChildren(self.Tab)
    self.AnimationsTable = self.Tab:AddTable("", 2)
    --Debug.DumpS(self.Animations)
    for AnimationName,Animation in pairsByKeys(self.Animations) do
        local animRow = self.AnimationsTable:AddRow()
        local animName = animRow:AddCell():AddText(AnimationName)
        local buttonCell = animRow:AddCell()
        local allAnimAnims = getAllHeightmatchingAnims(Animation.Heightmatching)
        local animationPicker
        local previousButton = buttonCell:AddButton("<-")
        previousButton.OnClick = function()
            updateCombo(animationPicker, -1)
        end
        previousButton.SameLine = true
        animationPicker = buttonCell:AddCombo("")
        animationPicker.Options = allAnimAnims
        animationPicker.OnChange = function ()
            Debug.Print("Combo OnChange")
            if animationPicker.SelectedIndex ~= 0 then
                UIEvents.ChangeAnimation:SendToServer({
                    ID = USERID,
                    Caster = _C().Uuid.EntityUuid,
                    Animation = animationPicker.Options[animationPicker.SelectedIndex + 1]
                })
            end
        end
        animationPicker.SameLine = true
        local nextButton = buttonCell:AddButton("->")
        nextButton.OnClick = function()
            updateCombo(animationPicker, 1)
        end
        nextButton.SameLine = true
        table.insert(self.AnimationPickers, {Previous = previousButton, AnimationPicker = animationPicker, Next = nextButton})
    end
    
    Debug.USEPREFIX = debugbefore
end

Log = {}
Log.__index = Log
function DebugTab:NewLog()
    local instance = setmetatable({
        Log = self.Tab:AddInputText("")
    }, Log)
    return instance
end

function Log:Update(txt)
    self.Log.Text = txt
end