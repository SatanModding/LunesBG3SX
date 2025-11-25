local BG3AF = {}
if BG3AFActive then
    BG3AF = Mods.BG3AF
end

Data.AnimationSets = { -- Check BG3AF about what Slot and Type means
    ["BG3SX_Body"] = {Resource = "bfa9dad2-2a5b-45cc-b770-9537badf9152", Slot = 0, Type = "Visual"},
    ["BG3SX_Loco"] = {Resource = "0c914b3f-5f24-441b-9be6-c25f4a424cfa", Slot = 0, Type = "Visual"},
    ["BG3SX_Idle"] = {Resource = "284eea6d-c693-4e4f-8527-f40433169e0c", Slot = 0, Type = "Visual"},
    ["BG3SX_Head"] = {Resource = "f1bc6e5c-9a1b-418b-8c23-23b8d98caf36", Slot = 1, Type = "VisualSet"},
    ["BG3SX_Tail"] = {Resource = "71d2f8cc-22e3-4aa6-b2af-3e34d87f6565", Slot = 1, Type = "VisualSet"},
    ["BG3SX_Wings"] = {Resource = "2a36331a-e834-488f-b6dd-c6ec68e083a5", Slot = 1, Type = "VisualSet"},
    ["BG3SX_Other"] = {Resource = "010d18d9-36a5-4625-b49b-84912e101818", Slot = 1, Type = "VisualSet"},
}
local sets = Data.AnimationSets

-- if Ext.IsServer() then -- because this file is loaded through _initData.lua which is also loaded on the client
    if BG3AFActive then
        local as = BG3AF.AnimationSet
        local body = as.Get(Data.AnimationSets["BG3SX_Body"].Resource) -- Gets an AnimationSet - Check BG3AF for options
        local head = as.Get(Data.AnimationSets["BG3SX_Head"].Resource) -- Gets an AnimationSet - Check BG3AF for options
        --local body = as.Get(Data.AnimationSets["BG3SX_Body"].Uuid) -- Gets an AnimationSet - Check BG3AF for options
        --local head = as.Get(Data.AnimationSets["BG3SX_Head"].Uuid)

        if Ext.IsServer() then
            Data.AnimLinks = {}
        end
        -- Create a new link between an animation ID and Mapkey on an AnimationSet

        local links = {
            --#region Start
            ["Start SFW"] = {MapKey = "c3af4377-7383-4aeb-a067-d8c36e82f716", AnimationID = "e333a111-8350-c192-152d-60a6a661462a"},
            ["EmbraceTop"] = {MapKey = "49d78660-5175-4ed2-9853-840bb58cf34a", AnimationID = "61a83621-65e3-400d-8444-58f3e8db3fb9"},
            ["EmbraceBtm"] = {MapKey = "10fee5b7-d674-436c-994c-616e01efcb90", AnimationID = "2ef3a003-54a9-4551-be7f-4f5e16d51dd3"},
            ["CarryingTop_Tall"] = {MapKey = "04922882-0a2d-4945-8790-cef50276373d", AnimationID = "516cb2de-500e-4a33-93e9-4339a4353dde"},
            ["CarryingBtm_Med"] = {MapKey = "392073ca-c6e0-4f7d-848b-ffb0b510500b", AnimationID = "0f6dc57f-a969-4e83-b8dc-212d90a35798"},
            --#endregion
            --#region Paired
            ["BlowjobTop"] = {MapKey = "536f0403-c401-4223-bbca-6b807494a527", AnimationID = "fe82152e-4283-43f5-bdb3-214bc64a7fec"},
            ["BlowjobBtm"] = {MapKey = "b3984708-7664-49ae-b96d-0512497ea036", AnimationID = "587dcf9c-b9de-4bb6-937c-e849f21cdf21"},
            ["EatOutTop"] = {MapKey = "5fa5cbe4-1baf-4529-b448-2c53e163626c", AnimationID = "ade67658-1366-423c-9cd9-33b58c8ca94a"},
            ["EatOutBtm"] = {MapKey = "f801ec0d-9fee-4584-bae3-96d7c3e285ff", AnimationID = "74d770cc-5f39-4a49-92b1-5de873068b93"},
            ["CowgirlTop"] = {MapKey = "ff7a5a30-b661-4192-bd8f-118373e3f4b8", AnimationID = "025720a9-ee9b-4e3c-9b90-d884b847bd9d"},
            ["CowgirlBtm"] = {MapKey = "1b220386-55fa-4d2b-8da4-0e7bf453d928", AnimationID = "7dcefc5b-85b6-4373-94d0-9eb5224a2e2c"},
            ["DoggyTop"] = {MapKey = "b8f04918-c5b6-4c4a-aee5-390bfaff33bc", AnimationID = "96c374fa-0559-4f2c-bc15-d76fda8704c9"},
            ["DoggyBtm"] = {MapKey = "ffdd67e7-7363-46a4-92e2-38260ef0a2e0", AnimationID = "3c6bb4b8-3a74-416f-95d1-2685aba044a9"},
            ["FingeringTop"] = {MapKey = "adf1b790-da1d-4aaf-9ac4-83157c52d5c2", AnimationID = "ba6b9eda-199c-4f04-bfd7-2b7dc05be633"},
            ["FingeringTop_P"] = {MapKey = "dcbc520b-f15f-498e-a829-c497a41f838f", AnimationID = "be7b9cfa-8a63-4eb8-be20-cc6757b180d3"},
            ["FingeringBtm"] = {MapKey = "a79232a2-a498-4689-a5bd-8923e80284d2", AnimationID = "8f8014b5-7a2e-44ad-a301-848b310b8a96"},
            ["LayingTop"] = {MapKey = "905be226-3edc-4783-9d4e-45d2b57a3d0a", AnimationID = "1de1d865-e3f9-4df2-8078-55af4bde7a77"},
            ["LayingBtm"] = {MapKey = "48a255e9-02ec-4541-b1b7-32275da29206", AnimationID = "5b99ad69-dd48-4e2d-b77f-0ce61deb93aa"},
            ["MilkingTop"] = {MapKey = "a71ace41-41ce-4876-8f14-4f419b677533", AnimationID = "97544a13-6602-4189-91ff-7302a69cf855"},
            ["MilkingBtm"] = {MapKey = "d2a17851-b51b-4e4f-be1d-30dc86b6466a", AnimationID = "de2af09d-c73a-4288-ad63-fdf8e2c930b9"},
            ["ScissorTop"] = {MapKey = "0114c60d-0f82-4827-ae11-9e3c46f7d7b5", AnimationID = "eb0e9053-f514-49e4-8b13-bcb942934eb0"},
            ["ScissorBtm"] = {MapKey = "8b9b1bb2-842b-422c-90ff-efbbe84835aa", AnimationID = "299ff183-1d48-4ca0-bcce-45f8372322ea"},
            --#endregion
            --#region Masturbation
            ["BottleSit"] = {MapKey = "d0f6cf4a-a418-4640-bf36-87531d55154b", AnimationID = "580daac5-3e82-4474-924c-6b7731cab169"},
            ["MasturbateStanding_V"] = {MapKey = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b", AnimationID = "1df05dff-b187-42ec-aacd-6ff99bcec62a"},
            ["MasturbateStanding_Tall_V"] = {MapKey = "2c60a233-b669-4b94-81dc-280e98238fd0", AnimationID = "2de90307-0134-44f7-9306-a019d2de30df"},
            ["MasturbateWank"] = {MapKey = "49497bdc-d901-4f60-9e4e-3d31a06f9002", AnimationID = "f3613d2c-b652-4dd7-b0f2-600e64afbdf4"},
            --#endregion
            --#region Experimental
            ["astarionTop"] = {MapKey = "26ea67ff-69ed-42be-88e3-8c63d4602908", AnimationID = "a856f395-1972-cfa4-9d1a-362f62a67590"},
            ["astarionBtm"] = {MapKey = "44eaa51b-b2e5-405d-80ef-f8e11cc26497", AnimationID = "3a38a294-f56c-4d59-90ab-8734b80f3f9f"},
            ["PenisTest"] = {MapKey = "2f9140db-696e-4eaf-8a7f-d5c3b4b8a6f1", AnimationID = "930a998f-65ad-487d-bd2a-3711a5b63190"},
            ["VampireLord"] = {MapKey = "e65aae61-ad31-4450-a1d6-7690627fcecb", AnimationID = "20df5080-d133-4d50-9652-8b594c98e2a9"},
            --#endregion
        }
        local headAnim = "cd8b98d1-5ae2-f4f7-ce9d-8b47a3252b4d" -- "Crying" AnimID for BG3SX
        local headIdle = "60b456ce-107e-909c-9d01-f6e309d31c8a" -- AnimID for head Idle animations
        local idles = { -- Regular idle animation MapKeys (Standing around)
            "392073ca-c6e0-4f7d-848b-ffb0b510500b",
            "04922882-0a2d-4945-8790-cef50276373d",
            "10fee5b7-d674-436c-994c-616e01efcb90",
            "49d78660-5175-4ed2-9853-840bb58cf34a"
        }

        -- AF TESTING
        -- local body = as.Get(sets["BG3SX_Body"].Uuid) -- bfa9dad2- is bg3sx specific animset, check Public/BG3SX/Content/Assets/[PAK]_AnimationSets
        -- local face = as.Get(sets["BG3SX_Head"].Uuid)
        for entry,content in pairs(links) do
            body:AddLink(content.MapKey, content.AnimationID, "")
            head:AddLink(content.MapKey, headAnim, "")
            if Ext.IsServer() then
                Data.AnimLinks[entry] = content
            end
        end
        for _,idle in pairs(idles) do
            head:AddLink(idle, headIdle)
        end
        -- Ext.Timer.WaitFor(5000, function()
            -- Debug.Print("Added AnimationSet links to BG3SX AnimationSet")
            -- local body = as.Get(sets["BG3SX_Body"].Uuid)
            -- _D(body[1].AnimationBank.AnimationSubSets[""].Animation)
        -- end)

        BG3AF.EmoteCollection.Create({
            ModuleUuid = ModuleUUID,
            ResourceUUID = "8c2f6e91-83ce-4b4f-b83f-dc0d289a058d",
            -- DisplayName = "BG3SX",
            Name = "BG3SX",
        })
    else
        Debug.Print("BG3AF not found")
    end
-- end

-- function Data.AnimationSets.AddSetToEntity(uuid, animationSet)
--     local character = uuid
--     local animWaterfall = Mods.BG3AF.AnimationWaterfall.Get(character)
--     local addedWaterfall = animWaterfall:AddWaterfall(animationSet.Uuid, animationSet.Slot, animationSet.Type)
--     -- _D(animWaterfall)
--     _D(addedWaterfall)
-- end

--[[
local char = Osi.GetHostCharacter()
local animSet = Mods.BG3SX.Data.AnimationSets
animSet.AddSetToEntity(char, animSet["BG3SX_Body"])
animSet.AddSetToEntity(char, animSet["BG3SX_Head"])
local animWaterfall = Mods.BG3AF.AnimationWaterfall.Get(char)
local waterfall = animWaterfall:GetWaterfall()
Osi.PlayAnimation(char, "ff7a5a30-b661-4192-bd8f-118373e3f4b8")
]]--

-- Some basic photomode stuff
-- We can move this later

