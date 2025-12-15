--- @class Dialog
--- @field private New fun(self:Dialog, timelineUuid: string): Dialog
--- @field Uuid string
--- @field TimelineUuid string
--- @field Window ExtuiWindow
--- @field OriginalSize number[]
--- @field OriginalPosition number[]
--- @field ResetWindow fun(self:Dialog)
--- @field Show fun(self:Dialog)
--- @field Hide fun(self:Dialog)
--- @field Clear fun(self:Dialog)
--- @field Timeline Timeline
Dialog = {}
Dialog.__index = Dialog

--- @class TimelineManager
--- @field Timelines table<string, Timeline>
--- @field Dialogs table<string, Dialog>
TimelineManager = {}
TimelineManager.__index = TimelineManager
TimelineManager.Timelines = {}

function Dialog:New(timelineUuid)
    local instance = setmetatable({
        Uuid = Helper.GenerateUUID(),
        TimelineUuid = timelineUuid,
    }, Dialog)
    return instance
end
function Dialog:Init()
    self.OriginalSize = {500,300}
    self.Window = Imgui.CreateCommonWindow("BG3SX Timeline",{
        Open = false,
        Closable = false,
        MinSize = self.OriginalSize,
        Size = self.OriginalSize,
    })
    self.Window.Open = true
    self.Window.Closeable = false
    self.Window.NoTitleBar = true
    self.Window.NoMove = true
    self.Window.NoResize = true
    self.Window.NoCollapse = true
    self.Window:SetColor("WindowBg", {0,0,0,0.25})

    -- local margin = {75,0}
    self.OriginalPosition = {
        ViewPort[1]/2 - self.OriginalSize[1]/2, -- Width
        ViewPort[2] - self.OriginalSize[2]-- Height
    }
    self.Window:SetPos(self.OriginalPosition)
    self.Window:AddText("Test")
end

function Dialog:ResetWindow()
    self.Window:SetSize(self.OriginalSize)
    self.Window:SetPos(self.OriginalPosition)
end
function Dialog:Show()
    self.Window.Open = true
end
function Dialog:Hide()
    self.Window.Open = false
end
function Dialog:Clear()
    Imgui.ClearChildren(self.Window)
end

function TimelineManager:AddTimeline(timeline)
    assert(timeline ~= nil, "[BG3SX] TimelineManager:AddTimeline - No timeline provided")
    assert(type(timeline) == "table", "[BG3SX] TimelineManager:AddTimeline - timeline is not a table")
    assert(self.Dialogs[timeline.Uuid] == nil, "[BG3SX] TimelineManager:AddTimeline - timeline already exists for UUID: " .. timeline.Uuid)
    self.Timelines[timeline.Uuid] = timeline
end

function TimelineManager:LoadTimeline(uuid, node)
    local node = node or 0
    assert(uuid ~= nil, "[BG3SX] TimelineManager:LoadTimeline - No UUID provided")
    assert(type(uuid) == "string", "[BG3SX] TimelineManager:LoadTimeline - UUID is not a string")
    if node then
        assert(type(node) == "number", "[BG3SX] TimelineManager:LoadTimeline - Node is not a number")
    end
    
    self.CurrentDialog = self.Timelines[uuid]
    self:GoTo(node)
    -- self.CurrentDialog.Timer
end

function TimelineManager:Init(timelineUuid)
    local newDialog = Dialog:New(timelineUuid)
    self.Dialogs[newDialog.Uuid] = newDialog
    newDialog:Init()
end

function TimelineManager:GoTo(node)
    assert(self.CurrentDialog ~= nil, "[BG3SX] TimelineManager:GoTo - No dialog loaded")
    assert(type(node) == "number", "[BG3SX] TimelineManager:GoTo - Node is not a number")
    assert(node ~= nil, "[BG3SX] TimelineManager:GoTo - No node provided")
    assert(self.Dialogs[self.CurrentDialog] ~= nil, "[BG3SX] TimelineManager:GoTo - No dialog found for UUID: " .. self.CurrentDialog)
    assert(self.Dialogs[self.CurrentDialog][node] ~= nil, "[BG3SX] TimelineManager:GoTo - No node found for UUID: " .. self.CurrentDialog .. " Node: " .. node)

    self.CurrentDialog.Node = node
    self:UpdateDialogContent()
end

function TimelineManager:UpdateDialogContent(dialogUuid)
    local dlg = self.Dialogs[dialogUuid]
    local t
    local function newTable()
        local t = dlg.Window:AddTable("", 3)
        t.SizingStretchSame = true
        return t
    end
    
    local function newRow()
        local row = t:AddRow()
        row:AddCell() -- Add empty cell to center align the next one
        return row
    end

    local function callTimelineNode(timelineNode)
        dlg:Clear()
        t = newTable()
        local row
        for i,node in ipairs(timelineNode) do
            if node.Flags then
                
            end
            local function callNodeData(nodeData)
                for _,call in ipairs(node.Data) do
                    if call.Type == "Text" then
                        row = newRow()
                        local txt = row:AddSelectable(call.Text)
                        txt.OnClick = function()
                            self.Selected = false
                            self:GoTo(call.Node)
                        end
                    elseif call.Type == "Animation" then
                        -- TimelineAnimation(uuid, animMapKey)
                    elseif call.Type == "Wait" then
                        Ext.Timer.WaitFor(call.Time * 1000, function()
                                callNodeData(call)
                        end)
                    end
                end
            end
            callNodeData(node.Data)
        end
        dlg.Window.Open = true
    end
    callTimelineNode(self.CurrentDialog.Nodes[self.CurrentDialog.Node])
end

-- function TimelineManager:Pause()
--     if self.Timer then
--         for _,timer in ipairs(self.Timer) do
--             timer:Stop()
--         end
--     end
-- end

--- @class DialogNode
--- @field Flags DialogNodeFlags
--- @field Data DialogNodeData

--- @alias DialogNodeData table<DialogNodeCallbacks>
--- @alias DialogNodeCallbacks table<DialogNodeCallback>
--- @alias DialogNodeCallback table<DialogNodeCallbackType, DialogNodeCallbackData>
--- @alias DialogNodeCallbackType string
--- @alias DialogNodeCallbackData table<DialogNodeCallbackDataType, any>
--- @alias DialogNodeCallbackDataType string

--- @class Timeline
--- @field Name string
--- @field Uuid string
--- @field Node number
--- @field Nodes table<number, DialogNode>
local testTimeline = {
    ["Name"] = "Test Timeline",
    ["Uuid"] = "bd23f28d-9c23-4085-a2bf-470f8a8ead88",
    ["IntendedSpeaker"] = {
        {
            ["Name"] = "IntendedSpeaker1",
            ["Uuid"] = "677dee82-c442-4cda-9fda-41981071ee9c",
        },
        {
            ["Name"] = "IntendedSpeaker2",
            ["Uuid"] = "de75c0c6-b364-41ff-a8b4-66444af6952d",
        },
    },
    ["Speaker"] = {
        {
            ["Name"] = "TestSpeaker1",
            ["Uuid"] = "4666b06d-f931-4d47-a60e-d5c7f94540e1",
        },
        {
            ["Name"] = "TestSpeaker2",
            ["Uuid"] = "ff6a4172-7fe9-4390-98a1-36543a52f245",
        },

    },
    ["Node"] = 0,
    ["Nodes"] = {
        [0] = {
            ["Flags"] = "IsRootNode", "ShowOnlyOnce",
            ["Data"] = {
                {Type = "Text", Text = "Hello World"},
                {Type = "Wait", Time = 1,
                    {Type = "Text", Text = "Bye World"},
                    {Type = "Animation", Target = "", Animation = "SomeUuid"},
                    {Type = "Wait", Time = 2,
                        {Type = "GoTo", Node = 1},
                    },
                },
            },
        },
        [1] = {
            ["Flags"] = "",
            ["Data"] = {
                {Type = "Text", Text = Ext.Loca.GetTranslatedString("","Greetings!")},
                {Type = "Wait", Time = 1,
                    {Type = "Text", Text = "Bye World"},
                    {Type = "Wait", Time = 2,
                        {Type = "GoTo", Node = 2},
                    },
                },
            },
        },
        [2] = {
            ["Flags"] = "",
            ["Data"] = {
                {Type = "Text", Text = "Hello World"},
                {Type = "Wait", Time = 1,
                    {Type = "Text", Text = "Bye World"},
                    {Type = "Wait", Time = 2,
                        {Type = "GoTo", Node = 3},
                    },
                },
            },
        },
        [3] = {
            ["Flags"] = "",
            ["Data"] = {
                {Type = "Text", Text = "Hello World"},
                {Type = "Wait", Time = 1,
                    {Type = "Text", Text = "Bye World"},
                    {Type = "Wait", Time = 2,
                        {Type = "GoTo", Node = 4},
                    },
                },
            },
        },
        [4] = {
            ["Flags"] = "",
            ["Data"] = {
                {Type = "Text", Text = "Hello World"},
                {Type = "Wait", Time = 1,
                    {Type = "Text", Text = "Bye World"},
                    {Type = "Wait", Time = 2,
                        {Type = "GoTo", Node = 0},
                    },
                },
            },
        },
    }
}
TimelineManager:AddTimeline(testTimeline)
-- TimelineManager:LoadTimeline(testTimeline.Uuid)