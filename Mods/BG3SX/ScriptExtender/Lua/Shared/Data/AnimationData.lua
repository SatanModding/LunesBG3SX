-- AnimationSets.lua needs to be loaded before AnimationData.lua to create and allow reusing of animations by name
if Ext.IsServer() then -- because this file is loaded through _initData.lua which is also loaded on the client
    local anim = Data.AnimLinks
    -- Heightmatching.lua needs to be loaded before AnimationData.lua to allow the functions to already exist.
    Ext.Require("Shared/Data/Heightmatching.lua")
    local hm = Heightmatching

    -- Seperated from Data.Animations because these 2 are the start spells which are handled differently and will create a scene
    Data.StartSexSpells = {
        ["StartMasturbating"] = {
            AnimLength = 3600, Loop = true, Fade = true, Sound = true, Category = {}, -- Fade and Sound currently don't do anything and could technically be left out when creating new entries
            SoundTop = Data.Sounds.Moaning,
            Heightmatching = hm:New("StartMasturbating", anim["MasturbateWank"].MapKey, anim["MasturbateStanding_V"].MapKey),
        },
        ["AskForSex"] = {
            AnimLength = 3600, Loop = true, Fade = true, Sound = false, Category = {}, 
            SoundTop = Data.Sounds.Silence, SoundBottom = Data.Sounds.Silence,
            Heightmatching = hm:New("AskForSex", anim["EmbraceTop"].MapKey, anim["EmbraceBtm"].MapKey),
        },
    }

    -- Additional entries need to be done seperately, we only create the instance per animation - We can't do this in the table belonging to the animation itself
    local hmi = hm.GetInstanceByAnimName("StartMasturbating")
    if hmi then -- Solo animation only needs to specify one bodytype/gender and one animation UUID
        hmi:SetAnimation("_P",  nil, anim["MasturbateWank"].MapKey)
        --hmi:SetAnimation("Tall_P",  nil, anim["MasturbateWank"].MapKey)
        hmi:SetAnimation("_V",  nil, anim["MasturbateStanding_V"].MapKey)
        hmi:SetAnimation("Tall_V",  nil, anim["MasturbateStanding_Tall_V"].MapKey) -- TallF specific animation - Tall is what we call the "Strong" bodytype identifier
    end
    local hmi = hm.GetInstanceByAnimName("AskForSex")
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
    local anims = Data.Animations

    function AddAnimation(name, category, animTop, animBtm, props)
        category = category or nil
        animBtm = animBtm or nil
        props = props or nil

        if not anims[name] then
            anims[name] = { -- Generic animation setup
                AnimLength = 3600, Loop = true, Fade = true, Sound = true, Category = category,
                SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning, Enabled = true,}

            if animBtm then
                anims[name].Heightmatching = hm:New(name, animTop, animBtm)
            else
                anims[name].Heightmatching = hm:New(name, animTop)
            end

            if props then
                anims[name].Props = props
            end

            Ext.Timer.WaitFor(100, function() -- To also send possible after-creation settings
                Ext.ModEvents.BG3SX.AddAnimation:Throw({anims[name]})
            end)
        else
            Debug.Print("An animation with this name already exists, please choose a different name or add an unique identifier")
        end
        return anims[name]
    end

    local function addAnim(name, category, animTop, animBtm, props)
        category = category or nil
        animBtm = animBtm or nil
        props = props or nil

        local anim = AddAnimation(name, category, animTop, animBtm, props)
        anim.Mod = ModuleUUID
        return anim
    end

    -- Animation Entries:
    ----------------------------------------------------
    local grinding = addAnim("Grinding", {"Lesbian"}, anim["ScissorTop"].MapKey, anim["ScissorBtm"].MapKey)
    grinding.Enabled = true
    local eatpussy = addAnim("EatPussy", {"Straight", "Lesbian", "Oral"},  anim["EatOutTop"].MapKey, anim["EatOutBtm"].MapKey)
    eatpussy.SoundTop = Data.Sounds.Kissing
    local fingerfuck = addAnim("FingerFuck", {"Straight", "Lesbian", "Gay", "Vaginal", "Anal"},  anim["FingeringTop"].MapKey, anim["FingeringBtm"].MapKey)
    fingerfuck.SoundTop = Data.Sounds.Kissing
    local blowjob = addAnim("Blowjob", {"Straight", "Oral"},  anim["BlowjobTop"].MapKey, anim["BlowjobBtm"].MapKey)
    blowjob.SoundTop = Data.Sounds.Kissing
    local laying = addAnim("Laying", {"Straight", "Gay", "Vaginal", "Anal"},  anim["LayingTop"].MapKey, anim["LayingBtm"].MapKey)
    local doggy = addAnim("Doggy", {"Straight", "Gay", "Vaginal", "Anal"},  anim["DoggyTop"].MapKey, anim["DoggyBtm"].MapKey)
    local cowgirl = addAnim("Cowgirl", {"Straight", "Gay", "Vaginal", "Anal"},  anim["CowgirlTop"].MapKey, anim["CowgirlBtm"].MapKey)
    cowgirl.SoundBottom = Data.Sounds.Kissing
    local milking = addAnim("Milking", {"Straight", "Gay"},  anim["MilkingTop"].MapKey, anim["MilkingBtm"].MapKey)
    milking.SoundBottom = Data.Sounds.Kissing
    local masturbate = addAnim("MasturbateStanding", anim["MasturbateStanding_V"].MapKey)
    local wanking = addAnim("BWanking", {"Masturbation"},  anim["MasturbateWank"].MapKey)
    wanking.SoundBottom = Data.Sounds.Kissing
    local bottlesit = addAnim("BottleSit", {"Masturbation"},  anim["BottleSit"].MapKey, nil, {"0f2ccca6-3ce8-4271-aec0-820f6581c551"}) -- Prop: Bottle
    local vampireThrust = addAnim("YOUR_LAST_THRUST", {"Test"},  anim["VampireLord"].MapKey)

    -- Heightmatching:
    ----------------------------------------------------
    local hmi = hm.GetInstanceByAnimName("MasturbateStanding")
    if hmi then
        hmi:SetAnimation("Tall_V",  nil, anim["MasturbateStanding_Tall_V"].MapKey)
    end

    -- Data.FilteredAnimations = {}
    -- local filter = Data.FilteredAnimations
    -- filter.Straight = {}
    -- filter.Gay = {}
    -- filter.Lesbian = {}
    -- filter.Whatever = {}
    -- function CreateAnimationFilter()
    --     for AnimationName,Animation in pairs(Data.Animations) do
    --         for Category in pairs(Animation.Category) do
    --             Debug.Print("Animation " .. AnimationName .. " is part of Category " .. Category)
    --         end
    --     end
    -- end
    
end