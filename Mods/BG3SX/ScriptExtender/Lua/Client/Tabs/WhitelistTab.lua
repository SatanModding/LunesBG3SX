WhitelistTab = {}
WhitelistTab.__index = WhitelistTab

function UI:NewWhitelistTab()
    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Whitelist"),
    }, SettingsTab)
    return instance
end

function WhitelistTab:Initialize()
    self:FetchWhitelist()
end
function WhitelistTab.FetchWhitelist()
    UIEvents.FetchWhitelist:SendToServer({ID = UIInstance.ID})
end

function WhitelistTab:GenerateWhitelistArea()
    if self.Whitelist then
        Debug.Dump(self.Whitelist)
        
        -- Every type of whitelist gets its own header with different ways to deal with the data

        -- Whitelist - Every entry also may have entry.racesUsingTag with multiple entries
        self.WhitelistHeader = self.Tab:AddCollapsableHeader("Whitelist")
        for TagName,Content in pairs(self.Whitelist.Whitelist) do
            local whitelistTree = self.WhitelistHeader:AddTree(TagName)
            local tagTable = self.WhitelistHeader:AddTable("",2)
            local row = tagTable:AddRow()
            local uuid = row:AddCell():AddText(Content.TAG)
            local enabledStatus = row:AddCell():AddCombo("")
            if Content.Enabled == true then
                enabledStatus.Checked = true
                enabledStatus.OnChange = function()
                    enabledStatus.Checked = true
                end
            else
                enabledStatus.Checked = false
                enabledStatus.OnChange = function()
                    enabledStatus.Checked = false
                end
                if Content.Reason then
                    local tooltip = enabledStatus:Tooltip()
                    local tooltipText = tooltip:AddText(Content.Reason)
                end
            end
        end

        -- ModdedTags - Overrides entries of the whitelist ----- Maybe show before whitelist
        self.ModdedTagsHeader = self.Tab:AddCollapsableHeader("Modded Entries")
        local moddedTagsTable = self.ModdedTagsHeader:AddTable("", 3)
        for TagName,Content in pairs(self.Whitelist.ModdedTags) do
            local row = moddedTagsTable:AddRow()
            local name = row:AddCell():AddText(TagName)
            local uuid = row:AddCell():AddText(Content.TAG)
            local enabledStatus = row:AddCell():AddCombo("")
            if Content.Enabled == true then
                enabledStatus.Checked = true
                -- enabledStatus.OnChange = function()
                --     enabledStatus.Checked = true
                -- end
            else
                enabledStatus.Checked = false
                -- enabledStatus.OnChange = function()
                --     enabledStatus.Checked = false
                -- end
                if Content.Reason then
                    local tooltip = enabledStatus:Tooltip()
                    local tooltipText = tooltip:AddText(Content.Reason)
                end
            end
            enabledStatus.Disabled = true
        end

        -- Whitelisted Entities
        self.WhitelistedEntitiesHeader = self.Tab:AddCollapsableHeader("Whitelisted Entities")
        local whitelistedEntitiesTable = self.WhitelistedEntitiesHeader:AddTable("",2)
        for _,entry in pairs(self.Whitelist.Whitelisted) do
            local row = whitelistedEntitiesTable:AddRow()
            local name = row:AddCell():AddText(Helper.GetName(entry))
            local uuid = row:AddCell():AddText(entry)
        end
        
        -- Blacklisted Entities
        self.BlacklistedEntitiesHeader = self.Tab:AddCollapsableHeader("Blacklisted Entities")
        local blacklistedEntitiesTable = self.BlackistedEntitiesHeader:AddTable("",2)
        for _,entry in pairs(self.Whitelist.Blacklisted) do
            local row = blacklistedEntitiesTable:AddRow()
            local name = row:AddCell():AddText(Helper.GetName(entry))
            local uuid = row:AddCell():AddText(entry)
        end
    end
end