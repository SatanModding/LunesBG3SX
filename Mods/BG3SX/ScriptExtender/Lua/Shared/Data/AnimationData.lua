-- AnimationSets.lua needs to be loaded before AnimationData.lua to create and allow reusing of animations by name
if Ext.IsServer() then -- because this file is loaded through _initData.lua which is also loaded on the client
    local anim = Data.AnimLinks

    -- Heightmatching.lua needs to be loaded before AnimationData.lua to allow the functions to already exist.
    Ext.Require("Shared/Data/Heightmatching.lua")
    local hm = Heightmatching

    Data.Animations = {}
    local anims = Data.Animations
    Data.IntroAnimations = {}
    local intros = Data.IntroAnimations

    local AnimationData = {}
    AnimationData.__index = AnimationData
    function AnimationData.New(moduleUUID, name, animTop, animBtm, categories, props)
        local instance
        if moduleUUID then
            instance = setmetatable({
                Enabled = true,
                Name = name,
                Categories = categories or nil,
                Heightmatching = hm:New(moduleUUID, name, animTop, animBtm),
                Props = props or nil,
                Duration = 3600,
                Loop = true,
                Sound = false,
                SoundTop = nil,
                SoundBottom = nil
            }, AnimationData)
            instance._animTop = animTop
            instance._animBtm = animBtm
            return instance
        else
            Debug.Print("Creating an AnimationData metatable failed for animation " .. name .. ". Missing ModuleUUID!")
        end
    end

    function CreateAnimationData(moduleUUID, name, animTop, animBtm, categories, props)
        animBtm = animBtm or nil
        categories = categories or nil
        props = props or nil

        local animData = AnimationData.New(moduleUUID, name, animTop, animBtm, categories, props)

        if categories and Table.Contains(categories, "NSFW") then -- If its an NSFW animation enable/add sound by default
            animData.Sound = true
            animData.SoundTop = Data.Sounds.Moaning
            animData.SoundBtm = Data.Sounds.Moaning
        end

        if animData then

            Ext.Timer.WaitFor(100, function() -- To wait for mods editing their animation entry or adding their ModuleUUID before throwing the event
                Ext.ModEvents.BG3SX.AddAnimation:Throw({animData})
            end)

            return animData
        end
    end

    -- These 2 local functions need to be recreated by every modauthor wanting to add animations to our system
    -- So new animation entries are actually added to a subtable named after their modUUID
    
    local function addIntroAnim(name, animTop, animBtm, categories, props)
        animBtm = animBtm or nil
        categories = categories or nil
        props = props or nil

        if not intros[ModuleUUID] then
            intros[ModuleUUID] = {}
        end
        if not intros[ModuleUUID][name] then
            local anim = CreateAnimationData(ModuleUUID, name, animTop, animBtm, categories, props)
            intros[ModuleUUID][name] = anim
        else
            Debug.Print("An animation with the name (" .. name .. ") already exists for this mod, please choose a different name or add an unique identifier")
        end
        return anim
    end
    local function addMainAnim(name, animTop, animBtm, categories, props)
        animBtm = animBtm or nil
        categories = categories or nil
        props = props or nil

        if not anims[ModuleUUID] then
            anims[ModuleUUID] = {}
        end
        if not anims[ModuleUUID][name] then
            local anim = CreateAnimationData(ModuleUUID, name, animTop, animBtm, categories, props)
            anims[ModuleUUID][name] = anim -- Add it to the BG3SX table
            return anim
        else
            Debug.Print("An animation with the name (" .. name .. ") already exists for this mod, please choose a different name or add an unique identifier")
        end
    end

    -- Every other still gets shown, but these are the main categories we sort for
    Data.AnimationCategories = {
        "SFW", "NSFW", "Solo Penis", "Solo Vulva", "Masturbation", "Masturbate", "Paired", "Straight", "Same-Sex", "Lesbian", "Gay", "Vaginal", "Oral", "Anal", "Third-Wheel"
    }
    Data.GenitalTypes = {
        "Regular", "Strap-On", "Strapon", "StrapOn", "Tentacle"
    }

    -- Animation Entries:
    ----------------------------------------------------
    -- Each of these is a metatable with additional parameters to set via object.Parameter, see AnimationData.New() -- Example: askForSex.Enabled = false
    
    -- Seperated from Data.Animations because these 2 are the start spells which are handled differently and will create a scene
    local startMasturbating = addIntroAnim("Start Masturbating", anim["MasturbateWank"].MapKey, anim["MasturbateStanding_V"].MapKey, {"NSFW", "Solo"})
    
    local askForSex = addIntroAnim("Ask for Sex", anim["EmbraceTop"].MapKey, anim["EmbraceBtm"].MapKey, {"SFW", "NSFW"})
        
    -- Setting up heightmatching matchups
    local hmi = startMasturbating.Heightmatching
    if hmi then -- Solo animation only needs to specify one bodyIdentifier and one animation UUID, the second body has to be set to nil
        hmi:SetAnimation("_P",  nil, anim["MasturbateWank"].MapKey)
        --hmi:SetAnimation("Tall_P",  nil, anim["MasturbateWank"].MapKey) -- Animation doesn't exist - Anyone with a penis would play this regardless because of the previous entry
        hmi:SetAnimation("_V",  nil, anim["MasturbateStanding_V"].MapKey)
        hmi:SetAnimation("Tall_V",  nil, anim["MasturbateStanding_Tall_V"].MapKey) -- TallF specific animation - Tall is what we call the "Strong" bodytype identifier
    end
    local hmi = askForSex.Heightmatching
    if hmi then -- Instead of a specific bodytype/gender combo, just the bodytype matchup also works
        hmi:SetAnimation("Tall", "Med", anim["CarryingTop_Tall"].MapKey, anim["CarryingBtm_Med"].MapKey)
        -- hmi:SetAnimation("Med", "Tall", "392073ca-c6e0-4f7d-848b-ffb0b510500b", "04922882-0a2d-4945-8790-cef50276373d")
        -- If we'd reverse the entry with the commented out line, the same animation would play even if we use SwitchPlaces
        -- Like this, if we initiate with Tall + Med, the carrying animation plays, if we use SwitchPlaces, the regular fallback plays
    end

    -- Additional Heightmatching Explanation
    ----------------------------------
    -- The way heightmatching animations get chosen is based on a Needleman-Wunsch algorithm
    -- In short, this means we assign different values to specific genital/bodyType/bodyShape combinations based on which heightmatching matchups have been set up for a given animation
    -- Meaning if it finds a good match based on some priorities within the matchup table and present bodies it uses the found matchup animation entries to play

    -- When creating matchups, use a combination of these identifiers:
    -- BodyType = {Tall, Med, Small, Tiny}
    -- BodyShape = {M, F}
    -- Genital = {_P, _V}

    -- Examples:
    -- TallM_P, Tall_P, Tall, _P, M, Med_V, MedF_P, TallF
    -- etc.
    -- But always write BodyType -> BodyShape -> Genital, from left to right, when you combine them!


    local grinding = addMainAnim("Grinding", anim["ScissorTop"].MapKey, anim["ScissorBtm"].MapKey, {"Lesbian"})

    local eatpussy = addMainAnim("EatPussy",  anim["EatOutTop"].MapKey, anim["EatOutBtm"].MapKey, {"Straight", "Lesbian", "Oral"})
    eatpussy.SoundTop = Data.Sounds.Kissing

    local fingerfuck = addMainAnim("FingerFuck",  anim["FingeringTop"].MapKey, anim["FingeringBtm"].MapKey, {"Straight", "Lesbian", "Gay", "Vaginal", "Anal"})
    fingerfuck.SoundTop = Data.Sounds.Kissing

    local blowjob = addMainAnim("Blowjob",  anim["BlowjobTop"].MapKey, anim["BlowjobBtm"].MapKey, {"Straight", "Oral"})
    blowjob.SoundTop = Data.Sounds.Kissing

    local laying = addMainAnim("Laying",  anim["LayingTop"].MapKey, anim["LayingBtm"].MapKey, {"Straight", "Gay", "Vaginal", "Anal"})

    local doggy = addMainAnim("Doggy",  anim["DoggyTop"].MapKey, anim["DoggyBtm"].MapKey, {"Straight", "Gay", "Vaginal", "Anal"})
    
    local cowgirl = addMainAnim("Cowgirl",  anim["CowgirlTop"].MapKey, anim["CowgirlBtm"].MapKey, {"Straight", "Gay", "Vaginal", "Anal"})
    cowgirl.SoundBottom = Data.Sounds.Kissing

    local milking = addMainAnim("Milking",  anim["MilkingTop"].MapKey, anim["MilkingBtm"].MapKey, {"Straight", "Gay"})
    milking.SoundBottom = Data.Sounds.Kissing

    local masturbateStanding = addMainAnim("Masturbate Standing", anim["MasturbateStanding_V"].MapKey, nil, {"SoloV"})

    local wanking = addMainAnim("Wanking",  anim["MasturbateWank"].MapKey, nil, {"SoloP"})
    wanking.SoundBottom = Data.Sounds.Kissing

    local bottlesit = addMainAnim("BottleSit",  anim["BottleSit"].MapKey, nil, {"Solo"}, {"0f2ccca6-3ce8-4271-aec0-820f6581c551"}) -- Prop: Bottle

    local vampireThrust = addMainAnim("YOUR_LAST_THRUST",  anim["VampireLord"].MapKey, nil, {"Test"})

    -- Heightmatching:
    ----------------------------------------------------
    local hmi = masturbateStanding.Heightmatching
    if hmi then
        hmi:SetAnimation("Tall_V",  nil, anim["MasturbateStanding_Tall_V"].MapKey)
    end

    -- Automatic NSFW Tag adding
    for uuid,modanims in pairs(anims) do
        if uuid == ModuleUUID then -- Only for this mod
            for name,animData in pairs(modanims) do
                -- Debug.Print("Dump " .. name)
                -- Debug.Dump(animData.Categories)
                if not Table.Contains(animData.Categories, "NSFW") then
                    table.insert(animData.Categories, "NSFW")
                    -- _D(animData.Categories)
                end
                animData.SoundTop = Data.Sounds.Moaning
                if animData._animBtm then
                    if Table.Contains(animData.Categories, "Lesbian") then
                        animData.SoundBottom = Data.Sounds.Kissing
                    else
                        animData.SoundBottom = Data.Sounds.Moaning
                    end
                end
            end
        end
    end

    -- Data.FilteredAnimations = {}
    -- local filter = Data.FilteredAnimations
    -- filter.Straight = {}
    -- filter.Gay = {}
    -- filter.Lesbian = {}
    -- filter.Whatever = {}
    -- function CreateAnimationFilter()
    --     for AnimationName,Animation in pairs(Data.Animations) do
    --         for Category in pairs(Animation.Categories) do
    --             Debug.Print("Animation " .. AnimationName .. " is part of Categories " .. Category)
    --         end
    --     end
    -- end
    
end