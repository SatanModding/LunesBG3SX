Data.Statuses = {}

-- TODO: Actually remove these before a scene and change them back later
Data.Statuses.BodyScaleStatuses = {
    -- The list of statuses below was copied from OnApplyFunctors data of ALCH_ELIXIR_ENLARGE entry in
    -- <unpacked game data>/Gustav/Public/Honour/Stats/Generated/Data/Status_BOOST.txt
    "ENLARGE",
    "ENLARGE_DUERGAR",
    "REDUCE",
    "REDUCE_DUERGAR",
    "WYR_POTENTDRINK_SIZE_ENLARGE",
    "WYR_POTENTDRINK_SIZE_REDUCE",
    "MAG_COMBAT_QUARTERSTAFF_ENLARGE",
    "MAG_GIANT_SLAYER_LEGENDARY_ENLRAGE"
}

-- Unconscious/paralyzed/etc status types that should block scene creation
Data.Statuses.InvalidSceneStatusTypes = {
    "INCAPACITATED",  -- Covers KNOCKED_OUT, GRAPPLED, HOLD_PERSON, etc.
    "KNOCKED_DOWN" -- Covers UNCONSCIOUS ?
}

---@param uuid string
---@return boolean hasInvalidStatus
---@return string|nil statusType
function Data.Statuses.HasInvalidStatusType(uuid)
    for _, statusType in ipairs(Data.Statuses.InvalidSceneStatusTypes) do
        local hasStatusType = Osi.HasAppliedStatusOfType(uuid, statusType)
        
        if hasStatusType == 1 then
            Debug.Print(string.format("[BG3SX] Character %s has status of type: %s", uuid, statusType))
            return true, statusType
        end
    end
    
    return false, nil
end