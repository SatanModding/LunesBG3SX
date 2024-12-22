

-- TODO Skiz. I need an autoerection setting  and a Stop Sex button

UI = {}
UI.__index = UI
UI.DevMode = false
UI.SelectingTarget = false
function UI.CreateDevMode(parent)
    local dev = parent:AddCheckbox("Developer Mode")
    dev.Visible = false -- NYI
    dev.OnChange = function()
        if dev.Checked == true then
            UI.DevMode = true
        else
            UI.DevMode = false
        end
    end
    return dev
end
function UI.InDev()
    if UI.DevMode == true then
        return true
    else return false
    end
end

function UI.HighlightConnected(tableToHighlight, listOfTables)
    for _,entry in pairs(listOfTables) do
        if entry.table == tableToHighlight then
            entry.table.Borders = true
            -- Color it in a different color
        end
    end
end

function UI.HighlightOnlyOne(tableToHighlight, listOfTables)
    --FailColor = {1.0, 0.0, 0.0, 1.0},
    --SuccessColor = {0.0, 1.0, 0.0, 1.0},
    --NeutralColor = {0.7, 0.7, 0.7, 1.0},
    for _,entry in pairs(listOfTables) do
        if entry.table == tableToHighlight then
            entry.button.Tint = {1.0, 0.8, 0.3, 1.0} -- Neutral Selected Color -- Beige
            entry.selected = true
        else
            entry.button.Tint = {1.0, 1.0, 1.0, 1.0} -- Reset to regular
            entry.selected = false
        end
    end
end

---------------------------------------------------------------------------------------------------
--                                    Handle Sex Settings Tab
---------------------------------------------------------------------------------------------------
local options = {
    ["Strip"] = {val = true, info = "", box = nil},
    ["Unlock Animation Choice"] = {val = false, info = "", box = nil},
}

function UI.CreateSexSettings(tBar)
    local tab = tBar:AddTabItem("Sex Settings")
    local table = tab:AddTable("",1)
    for option,content in pairs(options) do
        local cell = table:AddRow():AddCell()
        local optionCheckBox = cell:AddCheckbox(option)
        if content.val == true then
            optionCheckBox.Checked = true
        end
        optionCheckBox.OnChange = function()
            if optionCheckBox.Checked == true then
                content.val = true
                --Ext.Net.SendMessageToServer("BG3SX_" .. option, "") -- Setting this to true means we need to be able to show 
            else
                content.val = false
            end
        end
        local info = cell:AddText(content.info)
        options[option].box = optionCheckBox -- Might create infinite loop if someone dumps "options"
    end
    return tab
end

---------------------------------------------------------------------------------------------------
--                                  Handle Genital Settings Tab
---------------------------------------------------------------------------------------------------

local genitals = {}
function UI.GetUIGenitals()
    return genitals
end
local function OnSessionLoaded()

    -- TODO SKIZ 
    -- The inactive and active gential labels can be populated by
    -- calling SexUserVars:GetGenital("BG3SX_Flaccid", uuid) and SexUserVars:GetGenital("BG3SX_Erect", uuid)



    Ext.Net.PostMessageToServer("BG3SX_Client_RequestGenitals", "")
    function UI.CreateGenitalSettings(tBar)
        local idContextCount = 0
        local tab = tBar:AddTabItem("Genital Settings")

        local favArea = tab:AddTable("",2)
        favArea.SizingStretchProp = true
        local favRow = favArea:AddRow()
        local inactiveGArea = favRow:AddCell() -- Left
        local inactiveGInfo = inactiveGArea:AddText("Inactive Genital")
        local inactiveGSource = inactiveGArea:AddText("Source: ")
        local inactiveGenital = inactiveGArea:AddText("Genital: ")
        local activeGArea = favRow:AddCell() -- Right
        local activeGInfo = activeGArea:AddText("Active Genital")
        local activeGSource = activeGArea:AddText("Source: ")
        local activeGenital = activeGArea:AddText("Genital: ")

        tab:AddSeparator("")

        local function addGenitalEntry(parent, genital, mod)
            idContextCount = idContextCount + 1
            local inactiveGButton = parent:AddButton("Inactive")
            inactiveGButton.IDContext = "Inactive_GButton_" .. idContextCount
            local activeGButton = parent:AddButton("Active")
            activeGButton.IDContext = "Active_GButton_" .. idContextCount
            local GText = parent:AddText(genital.name)
            activeGButton.SameLine = true
            GText.SameLine = true
            inactiveGButton.OnClick = function()
                inactiveGSource.Label = "Source: " .. mod
                inactiveGenital.Label = "Genital: " .. genital.uuid
                -- TODO Skiz - also send uuid of host
                local uuid = nil
                Ext.Net.PostMessageToServer("BG3SX_Client_ChangedInactiveGenital", Ext.Json.Stringify({uuid = uuid, genital = genital.uuid}))
            end
            activeGButton.OnClick = function()
                activeGSource.Label = mod
                activeGenital.Label = "Genital: " .. genital.uuid
                -- TODO Skiz - also send uuid of host
                local uuid = nil
                Ext.Net.PostMessageToServer("BG3SX_Client_ChangedActiveGenital", Ext.Json.Stringify({uuid = uuid, genital = genital.uuid}))
            end
        end

        local genitalTable = tab:AddTable("",1)
        local genitalArea = genitalTable:AddRow():AddCell()
        genitalTable.SizingStretchProp = true
    
        for mod,content in pairs(genitals) do
            local modHeader = genitalArea:AddCollapsingHeader(tostring(mod))
            modHeader.DefaultOpen = false
            for type,genitals in pairs(content) do
                local typeHeader = modHeader:AddTree(tostring(type))
                typeHeader.DefaultOpen = false
                if typeHeader.Label == type then
                    for _,genital in pairs(genitals) do
                        addGenitalEntry(typeHeader, genital, tostring(mod))
                    end
                end
            end
        end
        return tab
    end
end
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

---------------------------------------------------------------------------------------------------
--                                   Handle Sex Controls Tab
---------------------------------------------------------------------------------------------------

function UI.DoSexButtonStuff(button)
    if button.Label == "Masturbate" then
        local selectedCharacter = UI.GetSelectedCharacter()
        if selectedCharacter ~= nil then
            Ext.Net.PostMessageToServer("BG3SX_Client_Masturbate", Ext.Json.Stringify({selectedCharacter}))
            -- for genitals
            SatanPrint(GLOBALDEBUG, "Client sending BG3SX_AskForSex to server")
            Ext.Net.PostMessageToServer("BG3SX_AskForSex",Ext.Json.Stringify({selectedCharacter}))
        end
    elseif button.Label == "Ask for Sex" then
        UI.SelectingTarget = true
    end
end


local preSexControls = {
    "Masturbate",
    "Ask for Sex"
}
local sceneTables = {

}
function UI.CreateSexControls(tBar)
    local tab = tBar:AddTabItem("Sex")
    
    local noSceneTable = tab:AddTable("",1)
    local sceneTable = tab:AddTable("",1)
    table.insert(sceneTables, noSceneTable)
    table.insert(sceneTables, sceneTable)

    -- No Scene exists for selected character
    local noSceneArea = noSceneTable:AddRow():AddCell()
    for _,entry in pairs(preSexControls) do
        local sexButton = noSceneArea:AddButton(entry)
        sexButton.SameLine = true
        sexButton.OnClick = function()
            UI.DoSexButtonStuff(sexButton)
            -- makes button invisible to replace it with the scene one
            -- noSceneTable.Visible = false
            sceneTable.Visible = true
        end
    end
    return tab
end

---------------------------------------------------------------------------------------------------
--                                    Handle Character Table
---------------------------------------------------------------------------------------------------


local characterTables = {}
function UI.GetSelectedCharacter()
    for _,entry in pairs(characterTables) do
        if entry.selected == true then
            return entry.uuid
        end
    end
end

function UI.FindCharacterTable(uuid)
    for _,entry in pairs(characterTables) do
        if entry.uuid == uuid then
            return entry.table
        end
    end
end

function UI.CharacterButton(table)
    UI.HighlightOnlyOne(table, characterTables)
    --DoSomethingElse
    --Refresh Info in Tabs
end

function UI.AddCharacter(parent, uuid)
    local character = Ext.Entity.Get(uuid)
    local charTable = parent:AddCell():AddTable("", 1)
    charTable.SizingStretchProp = true
    --charTable.Borders = true
    local row = charTable:AddRow()
    local size = {100,100}
    local tName = Ext.Loca.GetTranslatedString(character.DisplayName.NameKey.Handle.Handle)
    local characterButton
    local foundOrigin = false
    for uuid,origin in pairs(Data.Origins) do
        if Helper:StringContains(uuid, character.Uuid.EntityUuid) then
            foundOrigin = true
            characterButton = row:AddCell():AddImageButton("","EC_Portrait_"..origin, size)
        end
    end
    if foundOrigin == false then
        characterButton = row:AddCell():AddImageButton("","EC_Portrait_Generic", size)
    end

    characterButton.OnClick = function()
        UI.CharacterButton(charTable)
    end
    --local infoArea = row:AddCell():AddTable("", 1)
    local characterName = charTable:AddRow():AddCell():AddText("")
    characterName.Label = tName
    --local additionalInfo = infoArea:AddRow():AddCell():AddText("AdditionalInfoArea")
    table.insert(characterTables, {uuid = uuid, table = charTable, button = characterButton})
    return charTable
end


--TODO - Osi.DB_Partymembers not available on client
function UI.CreateCharacterTable(parent)
    local charTable = parent:AddTable("characterTable", 4)
    charTable.SizingStretchProp = true
    --charTable.Borders = true
    charTable.ScrollY = false
    --charTable.ScrollX = true
    local row = charTable:AddRow()
    --row:AddCell():AddText("Test")
    local characterCount = 0
    local party = UIHelper:GetCurrentParty()
    for _, uuid in pairs(party) do
        if characterCount > 0 and characterCount % 4 == 0 then
            row = charTable:AddRow()
        end
        --if Entity:IsWhitelisted(uuid, false) then
            local companion = UI.AddCharacter(row, uuid)
            characterCount = characterCount + 1
        --end
    end
    return charTable
end

---------------------------------------------------------------------------------------------------
--                                         Build UI
---------------------------------------------------------------------------------------------------

local function createModTab(tab)
    local dev = UI.CreateDevMode(tab)
    local characters = UI.CreateCharacterTable(tab)
    
    tab:AddSeparator("")

    local tBar = tab:AddTabBar("insertTabBarNameHere")
    local tab1 = UI.CreateSexControls(tBar)
    local tab2 = UI.CreateGenitalSettings(tBar)
    local tab3 = UI.CreateSexSettings(tBar)



end

---------------------------------------------------------------------------------------------------
--                                          Mouseover
---------------------------------------------------------------------------------------------------

local function getMouseover()
    local mouseover = Ext.UI.GetPickingHelper(1)
    if mouseover ~= nil then
    -- setSavedMouseover(mouseover)
        return mouseover
    else
        _P("[BG3SX] Not a viable mouseover!")
    end 
end

local function getUUIDFromUserdata(mouseover)
    local entity = mouseover.Inner.Inner[1].GameObject
    if entity ~= nil then
        return Ext.Entity.HandleToUuid(entity)
    else
        _P("[BG3SX] getUUIDFromUserdata(mouseover) - Not an entity!")
    end
end

--Ext.Events.KeyInput:Subscribe(function (e)
--    if e.Event == "KeyDown" and e.Repeat == false then
--        if e.Key == "F" then
--            if UI.SelectingTarget == true then
--                local caster = UI.GetSelectedCharacter()
--                local target = getUUIDFromUserdata(getMouseover())
--                Ext.Net.PostMessageToServer("BG3SX_Client_AskForSex", Ext.Json.Stringify({caster = caster, target = target}))
--                -- genitals
--                Ext.Net.PostMessageToServer("BG3SX_AskForSex",Ext.Json.Stringify({caster, target}))
--                UI.SelectingTarget = false
--            end
--        end
--        if e.Key == "Escape" then
--            sceneTables.noSceneTable.Visible = true
--            sceneTables.sceneTable.Visible = false
--            UI.SelectingTarget = false
--        end
--    end
--end)

---------------------------------------------------------------------------------------------------
--                                       NetListener
---------------------------------------------------------------------------------------------------

Ext.RegisterNetListener("BG3SX_Server_DistributeGenitals", function(e, payload)
    local payload = Ext.Json.Parse(payload)
    genitals = payload
end)
            
---------------------------------------------------------------------------------------------------
--                                       Load MCM Tab
---------------------------------------------------------------------------------------------------

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "BG3SX", function(mcm)
    UI.New(mcm)
end)


-------------------------------------------------
-- New stuff - Replace old stuff with new stuff
-------------------------------------------------

UIInstances = {}

function UI.New(mcm)
    local workingArea
    local mcm = mcm or nil

    if mcm then
        --workingArea = mcm.ParentElement.ParentElement -- Get the Parent of the Tabs Tabbar
        --UI.DestroyChildren(workingArea)
        workingArea = mcm:AddChildWindow("")
    else
        workingArea = Ext.IMGUI.NewWindow("")
    end

    local id = #UIInstances + 1
    local instance = setmetatable({
        ID = id,
        Window = workingArea,
        HotKeys = {},
    }, UI)

    instance:Initialize()
    table.insert(UIInstances, instance)
    return instance
end 

SceneInterface = {}
SceneInterface.__index = SceneInterface
function SceneInterface.New(UI)
    local instance = setmetatable({
        UI = UI.ID,
        Tab = UI.TabBar:AddTabItem("Scenes"),
    }, SceneInterface)
    return instance
end
GenitalInterface = {}
GenitalInterface.__index = GenitalInterface
function GenitalInterface.New(UI)
    local instance = setmetatable({
        UI = UI.ID,
        Tab = UI.TabBar:AddTabItem("Genitals"),
    }, GenitalInterface)
    return instance
end
SettingsInterface = {}
SettingsInterface.__index = SettingsInterface
function SettingsInterface.New(UI)
    local instance = setmetatable({
        UI = UI.ID,
        Tab = UI.TabBar:AddTabItem("Settings"),
    }, SettingsInterface)
    return instance
end

function UI:Initialize()
    self.TabBar = self.Window:AddTabBar("")
    self.SceneInterface = SceneInterface.New(self)
    self.GenitalInterface = GenitalInterface.New(self)
    self.SettingsInterface = SettingsInterface.New(self)
    self.SceneInterface:Initialize()
    self.GenitalInterface:Initialize()
    self.SettingsInterface:Initialize()
end

function SceneInterface:Initialize()
    local UI = UI.GetUIByID(self.UI)
    self.CurrentScenes = UI:GetScenes()
    self.SceneCount = nil
    self.NoSceneArea = self:CreateNewSceneArea()
end

function SceneInterface:CreateNewSceneArea()
    local table = self.Tab:AddTable("", 1)
    self.NoSceneText = table:AddRow():AddCell():AddText("No Scenes found, create one!")
    self.CreateSceneButton = table:AddRow():AddCell():AddButton("Create Scene")
    self.CreateSceneButton.OnClick = function()
        self:CreateScene()
    end
    return table
end

function SceneInterface:CreateScene()
    local UI = UI.GetUIByID(self.UI)
    UI:AwaitInput("NewScene")
end

function GenitalInterface:Initialize()
    self.Tab:AddText("Genitals TEST TEST")
end

function SettingsInterface:Initialize()
    local UI = UI.GetUIByID(self.UI)
    self.Tab:AddText("Hotkeys")
    UI.HotKeys.Select = self.Tab:AddCombo("Select - While awaiting Input")
    _D(UI.HotKeys)
    local combo = UI.HotKeys.Select
    for i,key in ipairs(Ext.Enums.SDLScanCode) do
        if not key == "UNKNOWN" then -- So this doesn't become selectable
            combo.Options[i] = key
        end
    end
    combo.OnChange = function()
        Debug.Print("Hotkey Changed to " .. combo.Value)
    end
end

function UI:AwaitInput(whatFor)
    if not self.EventListener then
        self.EventListener = UI:CreateListener()
    end
    self.Await = whatFor
end

function UI:CreateListener()
    local listener = Ext.Events.KeyInput:Subscribe(function (e)
        if e.Event == "KeyDown" and e.Repeat == false then
            if e.Key == self.HotKeys.Select.Value then
                if self.Await == "NewScene" then
                    self:InputRecieved(self.Await)
                end
            end
        end
    end)
    return listener
end

function UI:InputRecieved(whatFor)
    if whatFor == "NewScene" then
        self.Await = nil
        local caster = UI.GetSelectedCharacter()
        local target = getUUIDFromUserdata(getMouseover())
        Ext.Net.PostMessageToServer("BG3SX_Client_AskForSex", Ext.Json.Stringify({caster = caster, target = target}))
        -- genital function
        Ext.Net.PostMessageToServer("BG3SX_AskForSex",Ext.Json.Stringify({caster, target}))
        self.SceneInterface.NoSceneText.Visible = false
    end
end

function UI.DestroyChildren(obj)
    if obj.Children and #obj.Children > 0 then
        for _,child in pairs(obj.Children) do
            child:Destroy()
        end
    end
end

function UI.GetUIByID(id)
    for _,UI in pairs(UIInstances) do
        if UI.ID == id then
            return UI
        end
    end
end

function UI:GetScenes()
    self.AwaitingScenes = true
    UIEvents.FetchScenes:SendToServer("")
end
UIEvents.SendScenes:SetHandler(function (payload)
    if not payload == "Empty" then
        local scenes = payload
        for _,UI in pairs(UIInstances) do
            if UI.AwaitingScenes == true then
                UI.SceneInterface.CurrentScenes = scenes
                UI.SceneInterface.SceneCount = #scenes
                UI.AwaitingScenes = false
            end
        end
    end
end)
