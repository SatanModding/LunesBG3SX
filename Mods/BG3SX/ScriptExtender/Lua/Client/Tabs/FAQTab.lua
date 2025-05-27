---@class FAQTab
---@field Tab ExtuiTabItem

FAQTab = {}
FAQTab.__index = FAQTab

---@param holder ExtuiTabBar
---@
function FAQTab:New(holder)
    if UI.FAQTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        Tab = holder:AddTabItem("FAQ"),
    }, FAQTab)
    return instance
end

function FAQTab:Init()
    -- stuff goes here
end

return FAQTab