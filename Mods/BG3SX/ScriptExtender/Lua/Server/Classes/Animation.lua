----------------------------------------------------------------------------------------------------
-- 
--                             Animation Playing Handling [Mostly Timer based]
-- 
----------------------------------------------------------------------------------------------------


-- CONSTRUCTOR
--------------------------------------------------------------

local playAnimation
function Animation:New(actor, animSpell)

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


        local vars = Ext.Vars.GetModVariables(ModuleUUID)
        local unlocked = vars.BG3SX_ShowAllAnimations

        print("dumping scene")
        _D(scene.entities)
        

        if #scene.entities == 1 then
            instance.animation = hmInstance:NewGetAnimation(actor, unlocked)
        else
            hmAnim, hmAnim2 = hmInstance:NewGetAnimation(scene.entities[1], scene.entities[2], unlocked)
            if scene.entities[1] == instance.actor then
            print("entity is the first character (top)")
                instance.animation = hmAnim
            elseif scene.entities[2] == instance.actor then
             print("entity is the second character bottom")
                instance.animation = hmAnim2
            else
                Debug.Print("Something went wrong! Contact mod author! [Error 1]")
            end
        end

        -- Give Osi.Teleport time to teleport
        -- else the animation aborts


        -- TODO - check if timer is still necessary now that we dont use osi 


        -- TODO - check if on anim reset (when host has changed) a time ris still necessary
        --Ext.Timer.WaitFor(200, function ()
            playAnimation(instance) -- Automatically calls this function on creation
        --end)
        

        return instance
    else
        Debug.Print("Something went wrong! Contact mod author! [Error 2]")
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
    -- _P("[BG3SX][Animation.lua] - Animation:New() - playAnimation - Begin to play ", self.animation, " on ", self.actor.uuid)
end


-- used to play animation again when client control has changed (they stop playing the animation)
-- or to switch between vulva/penis animations when the genital has been changed while a scene is active
function Animation.ResetAnimation(character)
    -- while sex is active.... 

    print("resetting animation")
    local currentScene = Scene:FindSceneByEntity(character)
    if currentScene then
        print("scene exists. Resetting")
        -- ClientChanged takes a bit, If aniamtion is called too early, it gets reset again
        -- If we could put the animations "idle" we coudl circumvent this
        Ext.Timer.WaitFor(100, function ()
            playAnimation(Animation:New(character, currentScene.currentAnimation))
        end)
        
    end
end


-- When  a characters portrait is clicked, they reset. 
-- Try this workaround

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)  

    Ext.IO.SaveFile("host_trace_gainedControl.json", Ext.DumpExport(Ext.Entity.GetTrace()))

    Animation.ResetAnimation(target)

end)



