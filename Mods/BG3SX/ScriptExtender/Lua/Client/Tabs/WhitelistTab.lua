WhitelistTab = {}
WhitelistTab.__index = WhitelistTab

function UI:NewWhitelistTab()
    if self.WhiteListTab then return end -- Fix for infinite UI repopulation

    local instance = setmetatable({
        --UI = self.ID,
        Tab = self.TabBar:AddTabItem("Whitelist"),
    }, WhitelistTab)
    return instance
end

function WhitelistTab:Initialize()
    self.Tab:AddSeparatorText("(Read-only) Tags of selected character:")
    self.UserTags = {Header = self.Tab:AddCollapsingHeader("Character Tags")}
    self.Whitelists = {}
    self:FetchUserTags()
    self.Tab:AddSeparatorText("(Read-only) Whitelist")
    self:FetchWhitelist()
end

function WhitelistTab:FetchUserTags()
    UIEvents.FetchUserTags:SendToServer({ID = USERID, Character = _C().Uuid.EntityUuid})
end
function WhitelistTab:FetchWhitelist()
    UIEvents.FetchWhitelist:SendToServer({ID = USERID})
end

function WhitelistTab:GenerateWhitelistArea()
    if self.Whitelists then   
        for _,wList in pairs(self.Whitelists) do
            Table.SortData(wList)
            --Debug.Dump(wList)
        end

        -- Every type of whitelist gets its own header with different ways to deal with the data
        self:GenerateWhitelist()
        self:GenerateModdedWhitelist()
        self:GenerateWhitelistedEntities()
        self:GenerateBlacklistedEntities()        
    end
end

function WhitelistTab:IsAllowed(tag)
    return self.Whitelists.Whitelist[tag].Allowed
end
function WhitelistTab:GetReason(tag)
    return self.Whitelists.Whitelist[tag].Reason
end

function WhitelistTab:UpdateUserTags(tags)
    if self.UserTags.Header then
        UI.DestroyChildren(self.UserTags.Header)
    end
    self.UserTags.Tags = tags
    local header = self.UserTags.Header
    for _,tag in pairs(tags) do
        local name = Ext.StaticData.Get(tag, "Tag").Name
        local tagTreeNode = header:AddTree(name)
        local uuidText = tagTreeNode:AddText("UUID:")
        local uuid = tagTreeNode:AddInputText("")
        uuid.Text = tag
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
                if self.GetReason(tag) then
                    local tooltip = allowedStatus:Tooltip()
                    local tooltipText = tooltip:AddText(self:GetReason(tag))
                end
            end
        end
    end
end

function WhitelistTab:GenerateWhitelist()
-- Whitelist - Every entry also may have entry.racesUsingTag with multiple entries
    if not self.WhitelistHeader then
        self.WhitelistHeader = self.Tab:AddCollapsingHeader("Whitelist")
    end
    for TagName,Content in pairs(self.Whitelists.Whitelist) do
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
                    -- local tagText = tagTree:AddText("UUID:")
                    local uuid = tagTree:AddInputText("")
                    uuid.Text = Content.TAG
                    uuid.SameLine = true
                end
            end
        end
    end
end

function WhitelistTab:GenerateModdedWhitelist()
-- ModdedTags - Overrides entries of the whitelist ----- Maybe show before whitelist
    if not self.ModdedTagsHeader then    
        self.ModdedTagsHeader = self.Tab:AddCollapsingHeader("Modded Entries")
    end
    
    for TagName,Content in pairs(self.Whitelists.ModdedTags) do
        if Helper.IsUpperCase(TagName) then
            if TagName ~= "KID" and TagName ~= "GOBLIN_KID" then
                local tagTree = self.ModdedTagsHeader:AddTree(TagName)
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

function WhitelistTab:GenerateWhitelistedEntities()
-- Whitelisted Entities
    if not self.WhitelistedEntitiesHeader then
        self.WhitelistedEntitiesHeader = self.Tab:AddCollapsingHeader("Whitelisted Entities")
    end
    local whitelistedEntitiesTable = self.WhitelistedEntitiesHeader:AddTable("",2)
    for _,entry in pairs(self.Whitelists.Whitelisted) do
        local row = whitelistedEntitiesTable:AddRow()
        -- Debug.Print("Whitelist entry:")
        -- Debug.Dump(entry)
        local name = row:AddCell():AddText(Helper.GetName(entry))
        local uuid = row:AddCell():AddText(entry)
    end
end

function WhitelistTab:GenerateBlacklistedEntities()
-- Blacklisted Entities
    if not self.BlacklistedEntitiesHeader then
        self.BlacklistedEntitiesHeader = self.Tab:AddCollapsingHeader("Blacklisted Entities")
    end
    local blacklistedEntitiesTable = self.BlacklistedEntitiesHeader:AddTable("",2)
    for _,entry in pairs(self.Whitelists.Blacklisted) do
        local row = blacklistedEntitiesTable:AddRow()
        -- Debug.Print("Blacklist entry:")
        -- Debug.Dump(entry)
        local name = row:AddCell():AddText(Helper.GetName(entry))
        local uuid = row:AddCell():AddText(entry)
    end
end