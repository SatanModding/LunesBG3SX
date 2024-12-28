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
        actor = Helper:CleanPrefix(actor),
        animationData = animSpell, -- The chosen animations data table
        animation = ""
    }, Animation)
   

    local hmInstance = animSpell.Heightmatching
    local scene = Scene:FindSceneByEntity(actor)
    local hmAnim
    local hmAnim2
    if hmInstance then

        if #scene.entities == 1 then
            instance.animation = hmInstance:NewGetAnimation(actor)
        else
            hmAnim, hmAnim2 = hmInstance:NewGetAnimation(scene.entities[1], scene.entities[2])
            if scene.entities[1] == instance.actor then
                instance.animation = hmAnim
            elseif scene.entities[2] == instance.actor then
                instance.animation = hmAnim2
            else
                _P("[BG3SX][Animation.lua] Something went wrong! Contact mod author! [Error 1]")
            end
        end

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

  --  Osi.PlayAnimation(self.actor.uuid, "") -- First, stop current animation on actor
    if self.animationData.Loop == true then
        -- _P("Playing ", self.animation, " for ", self.actor.parent)
        Osi.PlayLoopingAnimation(self.actor, "", self.animation, "", "", "", "", "")
    else
        Osi.PlayAnimation(self.actor, self.animation)
    end
    -- _P("[BG3SX][Animation.lua] - Animation:new() - playAnimation - Begin to play ", self.animation, " on ", self.actor.uuid)
end


-- used to play animation again when client control has changed (they stop playing the animation)
-- or to switch between vulva/penis animations when the genital has been changed while a scene is active
function Animation.ResetAnimation(character)
    -- while sex is active.... 
    local currentScene = Scene:FindSceneByEntity(character)
    if currentScene then
        playAnimation(Animation:new(character, currentScene.currentAnimation))
    end
end


-- When  a characters portrait is clicked, they reset. 
-- Try this workaround

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)  

    Animation.ResetAnimation(target)

end)