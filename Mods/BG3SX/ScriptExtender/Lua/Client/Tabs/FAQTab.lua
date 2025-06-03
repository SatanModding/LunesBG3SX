

---@class FAQTab
---@field Tab ExtuiTabItem

FAQTab = {}
FAQTab.__index = FAQTab

local QuestionsAndAnswers = {
    Q_01 = {Qhandle = "ha37b1e058dce47878e1a2e7a70aa03223009", Ahandle = "h38f408132d3d49fea142807a3ceadcd2b350"},
    Q_02 = {Qhandle = "hb0e474b8282b4046b32a2becfd1ffea4b75c", Ahandle = "hb168cf0ac61f46bba340c563a603b7be377f"},
    Q_03 = {Qhandle = "h3508ad30db0442159391217fb7d043ea9f38", Ahandle = "h04d2f3f612e34ecc8faecbbc425f52af7996"},
    Q_04 = {Qhandle = "hff7ad4cb7c3d4dbdb23cf44716292361f3e7", Ahandle = "hfb7fd003577047968bea8d2259a88f4a2bdb"},
    Q_05 = {Qhandle = "h3e83c0f64c11487394781beeb0e7e34b6b6c", Ahandle = "h87416f4f5bbe410080bda5bff3905a00de3f"},
    Q_06 = {Qhandle = "h4fe2874431f64db9bbffe78e84151ebd070b", Ahandle = "h360a70255b314ef4ba0add19fae6ea2cfa5c"},
    Q_07 = {Qhandle = "h6f8f288c41e540aba1ca6c0ce8ea1b575508", Ahandle = "h787749887936488cba3f8e78e9a5266ea0d2"},
    Q_08 = {Qhandle = "h753f9a320f8448918cc3e7b478b7b13b713c", Ahandle = "h685436bd554e4ca2be7290cb64fcd0c9adg8"},
    Q_09 = {Qhandle = "h8dce960da44a44fea0514ad965eaca7de825", Ahandle = "h38922ab68a914a12b264139e12729dc30ag5"},
    Q_10 = {Qhandle = "hfd931f4e1ff84548b18959a913d40d747272", Ahandle = "h35c20084183a4a4b9d550d9b5b9feb203g6g"},
    Q_11 = {Qhandle = "h375760ad03b9430792a089a7dc57de87a424", Ahandle = "h095cd8c3767f4caa8f3c9352061e2210625b"},
    Q_12 = {Qhandle = "h7db9d559dd8d40e48f33b1f375d6edec8d14", Ahandle = "hba616357ba5c484ba567bc402e7546e30240"}
}

---@param holder ExtuiTabBar
function FAQTab:New(holder)
    if UI.FAQTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        Tab = holder:AddTabItem((Ext.Loca.GetTranslatedString("h96a223099d1e4ef6bdcf0b9caf5fcbbdc4cc"))),
    }, FAQTab)
    return instance
end

function FAQTab:Init()
    local faqGroup = self.Tab:AddGroup("FAQ")
    local showTabGroup = faqGroup:AddGroup("FAQ")
    showTabGroup:AddSeparatorText(Ext.Loca.GetTranslatedString("h96a223099d1e4ef6bdcf0b9caf5fcbbdc4cc"))

    self:GenerateFAQText()

end

function FAQTab:GenerateFAQText()
   local faqData = QuestionsAndAnswers

   for i = 1, #faqData, 1 do
    local qText = faqData[i].Qhandle
    local AText = faqData[i].Ahandle
   end
   Debug.Dump(faqData)
end


return FAQTab



