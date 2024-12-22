----------------------------------------------------------------------------------------------------
-- 
--                             Animation Playing Handling [Mostly Timer based]
-- 
----------------------------------------------------------------------------------------------------


-- CONSTRUCTOR
--------------------------------------------------------------

local playAnimation
function Animation:new(actor, animSpell)
    local instance = setmetatable({
        actor = actor,
        animationData = animSpell, -- The chosen animations data table
        animation = ""
    }, Animation)
   
 
    local hmInstance = animSpell.Heightmatching
    local scene = Scene:FindSceneByEntity(actor)
    local hmAnim
    local hmAnim2
    if hmInstance then

        print("hmInstance exists")

        if #scene.entities == 1 then
            instance.animation = hmInstance:getAnimation(actor)
        else
            hmAnim, hmAnim2 = hmInstance:getAnimation(scene.entities[1], scene.entities[2])
            if scene.entities[1] == instance.actor then
                instance.animation = hmAnim
            elseif scene.entities[2] == instance.actor then
                instance.animation = hmAnim2
            else
                _P("[BG3SX][Animation.lua] Something went wrong! Contact mod author! [Error 1]")
            end
        end

        print("calling playAnimation")


        -- Give Osi.Teleport time to teleport
        -- else the animation aborts
        Ext.Timer.WaitFor(200, function ()
            playAnimation(instance) -- Automatically calls this function on creation
        end)
        

        return instance
    else
        _P("[BG3SX][Animation.lua] Something went wrong! Contact mod author! [Error 2]")
    end
end

----------------------------------------------------------------------------------------------------
-- 
--                                             Start 
-- 
----------------------------------------------------------------------------------------------------

-- Stops remaining Animation and plays a new one
---@param actor         Actor   - The actor to play the animation with
---@param animationData Table   - The chosen animations data table
---@param animation     string  - The actual animation to play because there could be multiple ("Top"/"Bottom")
playAnimation = function(self)

    print("playing animation ", self.animation)

  --  Osi.PlayAnimation(self.actor.uuid, "") -- First, stop current animation on actor
    if self.animationData.Loop == true then
        -- _P("Playing ", self.animation, " for ", self.actor.parent)
        Osi.PlayLoopingAnimation(self.actor, "", self.animation, "", "", "", "", "")
    else
        Osi.PlayAnimation(self.actor, self.animation)
    end
    -- _P("[BG3SX][Animation.lua] - Animation:new() - playAnimation - Begin to play ", self.animation, " on ", self.actor.uuid)
end