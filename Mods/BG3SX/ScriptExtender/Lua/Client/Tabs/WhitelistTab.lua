---@class WhitelistTab
---@field Tab ExtuiTabItem
WhitelistTab = {}
WhitelistTab.__index = WhitelistTab

---@param holder ExtuiTabBar
function WhitelistTab:New(holder)
    if UI.WhitelistTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        Tab = holder:AddTabItem("Whitelist"),
    }, WhitelistTab)
    return instance
end

function WhitelistTab:Init()
    local sep = self.Tab:AddSeparatorText("(Read-only) Tags of selected character:")
    sep:SetStyle("SeparatorTextPadding", 5)
    self.UserTags = {Header = self.Tab:AddCollapsingHeader("Character Tags")}
    self.Whitelists = {}
    self:FetchUserTags()
    local sep = self.Tab:AddSeparatorText("(Read-only) Whitelist")
    sep:SetStyle("SeparatorTextPadding", 5)
    self:FetchWhitelist()
end

function WhitelistTab:FetchUserTags()
    Event.FetchUserTags:SendToServer({ID = USERID, Character = _C().Uuid.EntityUuid})
end
function WhitelistTab:FetchWhitelist()
    Event.FetchWhitelist:SendToServer({ID = USERID})
end

function WhitelistTab:GenerateWhitelistArea()
    if self.Whitelists then
        for _,wList in pairs(self.Whitelists) do
            Table.SortData(wList)
            --Debug.Dump(wList)
        end

        -- Every type of whitelist gets its own header with different ways to deal with the data
        self:GenerateModdedWhitelist()
        self:GenerateWhitelistedEntities()
        self:GenerateBlacklistedEntities()
        self:GenerateWhitelist()
    end

end

function WhitelistTab:IsAllowed(tag)
    return self.Whitelists.Whitelist[tag].Allowed
end
function WhitelistTab:GetReason(tag)
    if self.Whitelists and self.Whitelists.Whitelist and self.Whitelists.Whitelist[tag] and self.Whitelists.Whitelist[tag].Reason then
        return self.Whitelists.Whitelist[tag].Reason
    end
end

function WhitelistTab:UpdateUserTags(tags)
    if self.UserTags.Header then
        UI.DestroyChildren(self.UserTags.Header)
    end
    self.UserTags.Tags = tags
    local header = self.UserTags.Header
    local tagsByName = {}
    for _,tag in pairs(tags) do
        local name = Ext.StaticData.Get(tag, "Tag").Name
        if not tagsByName[name] then
            tagsByName[name] = {}
        end
        table.insert(tagsByName[name], tag)
    end
    table.sort(tagsByName)
    for name,tag in pairsByKeys(tagsByName) do
        local tagTreeNode = header:AddTree(name)
        local uuidText = tagTreeNode:AddText("UUID:")
        local uuid = tagTreeNode:AddInputText("")
        uuid.Text = tag[1]
        uuid.SameLine = true
        local allowedStatus = tagTreeNode:AddCheckbox("Allowed")
        allowedStatus.SameLine = true
        if self.Whitelists and Table.TableSize(self.Whitelists) > 0 then -- Only add an allowedStatus when WhitelistTab is found
            if self:IsAllowed(name) then
                allowedStatus.Checked = true
                allowedStatus.OnChange = function()
                    allowedStatus.Checked = true
                end
            else
                allowedStatus.Checked = false
                allowedStatus.OnChange = function()
                    allowedStatus.Checked = false
                end
                if self:GetReason(name) then
                    local tooltip = allowedStatus:Tooltip()
                    local tooltipText = tooltip:AddText(self:GetReason(name))
                else
                    local tooltip = allowedStatus:Tooltip()
                    local tooltipText = tooltip:AddText("No reason provided")
                end
            end
        end
    end
end

-- Whitelist - Every entry also may have entry.racesUsingTag with multiple entries
function WhitelistTab:GenerateWhitelist()
    if not self.WhitelistHeader then
        self.WhitelistHeader = self.Tab:AddCollapsingHeader("Whitelist")
    end
    table.sort(self.Whitelists.Whitelist)
    for TagName,Content in sortedPairs(self.Whitelists.Whitelist) do
        if Helper.IsUpperCase(TagName) then
            if TagName ~= "KID" and TagName ~= "GOBLIN_KID" then
                local tagTree = self.WhitelistHeader:AddTree(TagName)
                if Content.Allowed ~= nil then
                    local allowedStatus = tagTree:AddCheckbox("")
                    -- allowedStatus.SameLine = true
                    if Content.Allowed == true then
                        allowedStatus.Checked = true
                        allowedStatus.OnChange = function()
                            allowedStatus.Checked = true
                        end
                    else
                        allowedStatus.Checked = false
                        allowedStatus.OnChange = function()
                            allowedStatus.Checked = false
                        end
                        if Content.Reason then
                            local tooltip = allowedStatus:Tooltip()
                            local tooltipText = tooltip:AddText(Content.Reason)
                        end
                    end
                end
                if Content.TAG then
                    local uuid = tagTree:AddInputText("")
                    uuid.Text = Content.TAG
                    uuid.SameLine = true
                end
            end
        end
    end
end

-- ModdedTags - Overrides entries of the whitelist
function WhitelistTab:GenerateModdedWhitelist()
    if not self.ModdedTagsHeader then
        self.ModdedTagsHeader = self.Tab:AddCollapsingHeader("Modded Entries")
        self.ModdedTagsHeader.Visible = false
    end

    local modsByName = {}
    for uuid,mod in pairs(self.Whitelists.ModdedTags) do
        local name = Ext.Mod.GetMod(uuid).Info.Name
        if not modsByName[name] then
            modsByName[name] = {}
        end
        table.insert(modsByName[name], mod)
    end
    table.sort(modsByName)
    for modName,mod in pairsByKeys(modsByName) do
        local modTree = self.ModdedTagsHeader:AddTree(modName)
        for _,tags in pairs(mod) do
            for TagName,Content in sortedPairs(tags) do
                if Helper.IsUpperCase(TagName) then
                    if TagName ~= "KID" and TagName ~= "GOBLIN_KID" then
                        local tagTree = modTree:AddTree(tostring(TagName))
                        if Content.TAG then
                            local uuid = tagTree:AddInputText("Tag:")
                            uuid.Text = Content.TAG
                        end
                    if Content.Allowed ~= nil then
                            local allowedStatus = tagTree:AddCheckbox("Allowed")
                            allowedStatus.SameLine = true
                            if Content.Allowed == true then
                                allowedStatus.Checked = true
                                allowedStatus.OnChange = function()
                                    allowedStatus.Checked = true
                                end
                            else
                                allowedStatus.Checked = false
                                allowedStatus.OnChange = function()
                                    allowedStatus.Checked = false
                                end
                                if Content.Reason then
                                    local tooltip = allowedStatus:Tooltip()
                                    local tooltipText = tooltip:AddText(Content.Reason)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if self.ModdedTagsHeader.Children and #self.ModdedTagsHeader.Children > 0 then
        self.ModdedTagsHeader.Visible = true
    else
        self.ModdedTagsHeader.Visible = false
    end
end

-- Whitelisted Entities
function WhitelistTab:GenerateWhitelistedEntities()
    if not self.WhitelistedEntitiesHeader then
        self.WhitelistedEntitiesHeader = self.Tab:AddCollapsingHeader("Whitelisted Entities")
    end
    self.WhitelistedEntitiesHeader:AddText("Only shows names of loaded entities")
    local whitelistedEntitiesTable = self.WhitelistedEntitiesHeader:AddTable("",2)

    local entryByName = {}
    for _,entry in pairs(self.Whitelists.Whitelisted) do
        local name = Helper.GetName(entry)
        if name ~= "Name not Found" then
            if not entryByName[name] then
                entryByName[name] = {}
            end
            table.insert(entryByName[name], entry)
        end
    end
    table.sort(entryByName)
    for name,entry in pairsByKeys(entryByName) do
        local row = whitelistedEntitiesTable:AddRow()
        local uuid = entry[1]
        local nameText = row:AddCell():AddText(name)
        local uuidText = row:AddCell():AddInputText("")
        uuidText.Text = uuid
    end
end

-- Blacklisted Entities
function WhitelistTab:GenerateBlacklistedEntities()
    if not self.BlacklistedEntitiesHeader then
        self.BlacklistedEntitiesHeader = self.Tab:AddCollapsingHeader("Blacklisted Entities")
    end
    self.BlacklistedEntitiesHeader:AddText("Only shows names of loaded entities")
    local blacklistedEntitiesTable = self.BlacklistedEntitiesHeader:AddTable("",2)

    local entryByName = {}
    for _,entry in pairs(self.Whitelists.Blacklisted) do
        local name = Helper.GetName(entry)
        if name ~= "Name not Found" then
            if not entryByName[name] then
                entryByName[name] = {}
            end
            table.insert(entryByName[name], entry)
        end
    end
    table.sort(entryByName)
    
    for name,entry in pairsByKeys(entryByName) do
        local row = blacklistedEntitiesTable:AddRow()
        local uuid = entry[1]
        local nameText = row:AddCell():AddText(name)
        local uuidText = row:AddCell():AddInputText("")
        uuidText.Text = uuid
    end
end

return WhitelistTab