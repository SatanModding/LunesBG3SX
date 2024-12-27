-- AnimationSets.lua needs to be loaded before AnimationData.lua to create and allow reusing of animations by name
if Ext.IsServer() then -- because this file is loaded through _initData.lua which is also loaded on the client
    local anim = Data.AnimLinks
    -- Heightmatching.lua needs to be loaded before AnimationData.lua to allow the functions to already exist.
    Ext.Require("Shared/Data/Heightmatching.lua")
    local hm = Heightmatching

    -- Seperated from Data.Animations because these 2 are the start spells which are handled differently and will create a scene
    Data.StartSexSpells = {
        ["BG3SX_StartMasturbating"] = {
            AnimLength = 3600, Loop = true, Fade = true, Sound = true, -- Fade and Sound currently don't do anything and could technically be left out when creating new entries
            SoundTop = Data.Sounds.Moaning,
            Heightmatching = hm:New("BG3SX_StartMasturbating", anim["MasturbateWank"].MapKey, anim["MasturbateStanding_F"].MapKey),
        },
        ["BG3SX_AskForSex"] = {
            AnimLength = 3600, Loop = true, Fade = true, Sound = false,
            SoundTop = Data.Sounds.Silence, SoundBottom = Data.Sounds.Silence,
            Heightmatching = hm:New("BG3SX_AskForSex", anim["EmbraceTop"].MapKey, anim["EmbraceBtm"].MapKey),
        },
    }

    -- Additional entries need to be done seperately, we only create the instance per animation - We can't do this in the table belonging to the animation itself
    local hmi = hm:GetInstanceByAnimName("BG3SX_StartMasturbating")
    if hmi then -- Solo animation only needs to specify one bodytype/gender and one animation UUID
        hmi:SetAnimation("M",  nil, anim["MasturbateWank"].MapKey)
        hmi:SetAnimation("F",  nil, anim["MasturbateStanding_F"].MapKey)
        hmi:SetAnimation("TallF",  nil, anim["MasturbateStanding_TallF"].MapKey) -- TallF specific animation - Tall is what we call the "Strong" bodytype identifier
    end
    local hmi = hm:GetInstanceByAnimName("BG3SX_AskForSex")
    if hmi then -- Instead of a specific bodytype/gender combo, just the bodytype matchup also works
        hmi:SetAnimation("Tall", "Med", anim["CarryingTop_Tall"].MapKey, anim["CarryingBtm_Med"].MapKey)
        -- hmi:SetAnimation("Med", "Tall", "392073ca-c6e0-4f7d-848b-ffb0b510500b", "04922882-0a2d-4945-8790-cef50276373d")
        -- If we'd reverse the entry with the commented out line, the same animation would play even if we use SwitchPlaces
        -- Like this, if we initiate with Tall + Med, the carrying animation plays, if we use SwitchPlaces, the regular fallback plays
    end

    -- Additional Explanation
    ----------------------------------
    -- The way animations get chosen is based on this priority
    -- BodyShape+BodyType > BodyType > BodyShape
    -- TallM > M > Tall
    -- Meaning if it finds a match based on a combination of Shape and Type it uses this, otherwise it checks for Type matchups, then Shape matchups

    -- While creating matches, only use one of these matchups with the same type
    -- Only use Tall + Tall or Tall + Med matchups but never Tall + M or M + TallF
    -- If you want to match TallM against any F do it like this:
    -- TallM + TallF
    -- TallM + MedF
    -- etc.

    Data.Animations = {}
    function Data.Animations.New(name, category, animTop, animBtm, props)
        category = category or nil
        animBtm = animBtm or nil
        props = props or nil
        Data.Animations[name] = { -- Generic animation setup
            AnimLength = 3600, Loop = true, Fade = true, Sound = true, Category = category,
            SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning}
        if animBtm then
            Data.Animations[name].Heightmatching = hm:New(name, animTop, animBtm)
        else
            Data.Animations[name].Heightmatching = hm:New(name, animTop)
        end
        if props then
            Data.Animations[name].Props = props
        end
        return Data.Animations[name]
    end

    -- Animation Entries:
    ----------------------------------------------------
    local grinding = Data.Animations.new("BG3SX_Grinding", anim["ScissorTop"].MapKey, anim["ScissorBtm"].MapKey)
    local eatpussy = Data.Animations.new("BG3SX_EatPussy", anim["EatOutTop"].MapKey, anim["EatOutBtm"].MapKey)
    eatpussy.SoundTop = Data.Sounds.Kissing
    local fingerfuck = Data.Animations.new("BG3SX_FingerFuck", anim["FingeringTop"].MapKey, anim["FingeringBtm"].MapKey)
    fingerfuck.SoundTop = Data.Sounds.Kissing
    local blowjob = Data.Animations.new("BG3SX_Blowjob", anim["BlowjobTop"].MapKey, anim["BlowjobBtm"].MapKey)
    blowjob.SoundTop = Data.Sounds.Kissing
    local laying = Data.Animations.new("BG3SX_Laying", anim["LayingTop"].MapKey, anim["LayingBtm"].MapKey)
    local doggy = Data.Animations.new("BG3SX_Doggy", anim["DoggyTop"].MapKey, anim["DoggyBtm"].MapKey)
    local cowgirl = Data.Animations.new("BG3SX_Cowgirl", anim["CowgirlTop"].MapKey, anim["CowgirlBtm"].MapKey)
    cowgirl.SoundBottom = Data.Sounds.Kissing
    local milking = Data.Animations.new("BG3SX_Milking", anim["MilkingTop"].MapKey, anim["MilkingBtm"].MapKey)
    milking.SoundBottom = Data.Sounds.Kissing
    local masturbate = Data.Animations.new("BG3SX_MasturbateStanding", anim["MasturbateStanding_F"].MapKey)
    local wanking = Data.Animations.new("BG3SX_Wanking", anim["MasturbateWank"].MapKey)
    wanking.SoundBottom = Data.Sounds.Kissing
    local bottlesit = Data.Animations.new("BG3SX_BottleSit", anim["BottleSit"].MapKey, nil, {"0f2ccca6-3ce8-4271-aec0-820f6581c551"}) -- Prop: Bottle
    local vampireThrust = Data.Animations.new("YOUR_LAST_THRUST", anim["VampireLord"].MapKey)
    -- Heightmatching:
    ----------------------------------------------------
    local hmi = hm:GetInstanceByAnimName("BG3SX_MasturbateStanding")
    if hmi then
        hmi:SetAnimation("TallF",  nil, anim["MasturbateStanding_TallF"].MapKey)
    end
end