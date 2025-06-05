

---@class FAQTab
---@field Tab ExtuiTabItem

FAQTab = {}
FAQTab.__index = FAQTab

local QuestionsAndAnswers = {
    [1] = {Qhandle = "ha37b1e058dce47878e1a2e7a70aa03223009", Ahandle = "h38f408132d3d49fea142807a3ceadcd2b350", 
        Qbackup = "I don't see the spells in my hotbar", 
        Abackup = "Spells have been replaced by the UI you are reading this from. All spell functionalities have been split into different tabs. They are named appropriately."},
    [2] = {Qhandle = "hb0e474b8282b4046b32a2becfd1ffea4b75c", Ahandle = "hb168cf0ac61f46bba340c563a603b7be377f", 
        Qbackup = "How do I get the controls back after I closed the menu?", 
        Abackup = "When you create a scene, a window will pop up. This window is for THIS scene only. If you close it, it can be found underneath the 'New Scene' button, simply named after the characters that are involved."},
    [3] = {Qhandle = "h3508ad30db0442159391217fb7d043ea9f38", Ahandle = "h04d2f3f612e34ecc8faecbbc425f52af7996", 
        Qbackup = "I don't see any animation options for my pairing.", 
        Abackup = "End the scene and try selecting them again in the opposite order."},
    [4] = {Qhandle = "hff7ad4cb7c3d4dbdb23cf44716292361f3e7", Ahandle = "hfb7fd003577047968bea8d2259a88f4a2bdb", 
        Qbackup = "Why is this NPC not appearing?", 
        Abackup = "This might happen because of our whitelisting system, which was carried over from the old version. There are a lot of races that are simply incompatible with the animations or custom races which the author might just not want to be used with this mod. Check our discord for more information about our Whitelist if you have any more questions."},
    [5] = {Qhandle = "h3e83c0f64c11487394781beeb0e7e34b6b6c", Ahandle = "h87416f4f5bbe410080bda5bff3905a00de3f", 
        Qbackup = "Why do animations not play?", 
        Abackup = "This mod now requires the BG3AF - Animation Framework. Download it on Nexus",
        hasLink = "https://www.nexusmods.com/baldursgate3/mods/16207?tab=description"},
    [6] = {Qhandle = "h4fe2874431f64db9bbffe78e84151ebd070b", Ahandle = "h360a70255b314ef4ba0add19fae6ea2cfa5c", 
        Qbackup = "Is the mod safe to uninstall mid-game?", 
        Abackup = "It's generally advised to use Volitio's Mod Uninstaller before removing mods. A leftover spell or passive on an entity may otherwise lead to issues loading your save file.",
        hasLink = "https://www.nexusmods.com/baldursgate3/mods/9701"},
    [7] = {Qhandle = "h6f8f288c41e540aba1ca6c0ce8ea1b575508", Ahandle = "h787749887936488cba3f8e78e9a5266ea0d2", 
        Qbackup = "Can I use this mod in multiplayer?", 
        Abackup = "Yes. However, with the introduction of crossplay in Patch 8, do note that this mod 100% requires Script Extender. That means that platforms where Script Extender is not available cannot run this mod. This means: - This mod will never be on console. More information here or as a video here - This mod does not natively run on MacOS. If you can get Script Extender to run on Mac, then it “could” work. (No way for us to test this. You are on your own, but please report back.) - This mod runs on linux and therefore on the SteamDeck using a specific setup (for more information/a guide, please check the modding community wiki here:)",
        hasLink = "https://wiki.bg3.community/en/Tutorials/Mod-Use/How-to-install-Script-Extender#h-3-install-script-extender-on-linuxsteam-deck"},
    [8] = {Qhandle = "h753f9a320f8448918cc3e7b478b7b13b713c", Ahandle = "h685436bd554e4ca2be7290cb64fcd0c9adg8", 
        Qbackup = "Why does my [MODDED RACE] not work?", 
        Abackup = "See all information about this here",
        hasLink = "https://wiki.bg3.community/en/Tutorials/Mod-Integration/BG3SX/Whitelisting"},
    [9] = {Qhandle = "h8dce960da44a44fea0514ad965eaca7de825", Ahandle = "h38922ab68a914a12b264139e12729dc30ag5", 
        Qbackup = "Are there more animations?", 
        Abackup = "Tells you to look again for 'BG3SX' on Nexusmods"},
    [10] = {Qhandle = "hfd931f4e1ff84548b18959a913d40d747272", Ahandle = "h35c20084183a4a4b9d550d9b5b9feb203g6g", 
        Qbackup = "My character has the wrong genitals/animations.", 
        Abackup = "Are you using Oops All Futa (Penis) ? This mod conflicts with our internal genital logic and you will see wrong genitals/animations. We recommend you use our genital system to give female characters penises instead."},
    [11] = {Qhandle = "h7db9d559dd8d40e48f33b1f375d6edec8d14", Ahandle = "hba616357ba5c484ba567bc402e7546e30240", 
        Qbackup = "Why do my scenes randomly break?", 
        Abackup = "This might be due to your set auto-save interval. To ensure not breaking your save files in case you remove our mod at some point, we always destroy any ongoing scenes when the game enters into the saving state. The auto-save mod might cause problems here, make sure to keep that in mind."}
}

---@param holder ExtuiTabBar
function FAQTab:New(holder)
    if UI.FAQTab then return end -- Fix for infinite UI repopulation
    
    local instance = setmetatable({
        Tab = holder:AddTabItem(Ext.Loca.GetTranslatedString("h96a223099d1e4ef6bdcf0b9caf5fcbbdc4cc", "FAQ")),
    }, FAQTab)
    return instance
end

function FAQTab:Init()
    local faqGroup = self.Tab:AddGroup("FAQ")
    faqGroup:AddSeparatorText(Ext.Loca.GetTranslatedString("h96a223099d1e4ef6bdcf0b9caf5fcbbdc4cc", "FAQ"))

    self:GenerateFAQText()

end

function FAQTab:GenerateFAQText()
   local faqData = QuestionsAndAnswers

   local qText
   local aText
   local qBackup
   local aBackup
   local link

   for i = 1, #faqData, 1 do
    -- get info
    qText = faqData[i]["Qhandle"]
    aText = faqData[i]["Ahandle"]
    qBackup = faqData[i]["Qbackup"]
    aBackup = faqData[i]["Abackup"]

    if not self.questionHeader then
        self.questionHeader = self.Tab:AddCollapsingHeader((Ext.Loca.GetTranslatedString(qText, qBackup)))
    end

    self.questionHeader:AddText(Ext.Loca.GetTranslatedString(aText, aBackup))

    if faqData[i]["hasLink"] ~= nil then
        -- implement link if found
        link = faqData[i]["hasLink"]
        self.questionHeader:AddInputText("", link)
    end
    self.questionHeader.TextWrapPos = 0
    self.questionHeader = nil

   end
end


return FAQTab



