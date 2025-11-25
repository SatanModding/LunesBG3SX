----------------------------------------------------------------------------------------
--
--                               For handling Sound functionalities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

local playSound

-- Creates a new sound instance on an actor
---@param actor         Actor   - The actor to play it on
---@param animSpell     table   - Animation data for duration
function Sound:New(actor, animSpell)
    local instance = setmetatable({
        actor = actor,
        duration = animSpell.Duration
    }, Sound)
    playSound(instance) -- Automatically calls this function on creation

    return instance
end


-- Initialization
--------------------------------------------------------------

playSound = function(self)
    local scene = Scene.FindSceneByEntity(self.actor)
    if not scene then
        return  -- Scene destroyed, stop playing
    end
    
    -- fetch sound data dynamically from current animation
    local soundTable = nil
    if scene.currentAnimation then
        if Helper.StringContainsOne(scene.entities[1], self.actor) then
            soundTable = scene.currentAnimation.SoundTop
        else
            soundTable = scene.currentAnimation.SoundBottom or scene.currentAnimation.SoundTop
        end
    end
    
    local minRepeatTime = self.duration - 200
    local maxRepeatTime = self.duration + 200
    local nothing = "1f012ea2-236e-473c-b261-4523753ab9bb"
    Osi.PlaySound(self.actor, nothing) -- First, stop current sound

    if soundTable then
        local sound = soundTable[math.random(1, #soundTable)]
        if sound then
            Osi.PlaySound(self.actor, sound)
        end
    end
    
    -- Schedule next sound - will automatically fetch new soundTable on next loop
    local newSoundTimer = Ext.Timer.WaitFor(math.random(minRepeatTime, maxRepeatTime), function()
        playSound(self)  -- will fetch current animation's sounds
    end)
    scene:RegisterNewSoundTimer(newSoundTimer)
end