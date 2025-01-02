-------------------------------------------------------------------------------------------------------------
---
---                                 For Handling Visuals (CCAV/CCSV)
---                              For entities that are of GameObjectType = 2    
---                         They pull from entity.AppearanceOverride.Visual.Visuals
--- 
------------------------------------------------------------------------------------------------------------



Shapeshift = {}
Shapeshift.__index = Shapeshift


---@param entity EntityHandle 
function Shapeshift.IsShapeshifted(entity)

    if (entity.GameObjectVisual.Type == 4) or (entity.GameObjectVisual.Type == 2) then 
        return true
    else
        return false
    end
end



---@param entity EntityHandle 
---@param listToAdd table 
function Shapeshift.AddListOfVisuals(entity, listToAdd)

    if listToAdd then
        for _, entry in pairs(listToAdd) do
            Shapeshift.AddCustomVisualOverride(entity, entry)
        end
    end
end



---@param entity EntityHandle 
---@param listToRemove table 
function Shapeshift.RemoveListOfVisuals(entity, listToRemove)

    if listToRemove then
        for _, entry in pairs(listToRemove) do
            Shapeshift.RemoveCustomVisualOvirride(entity, entry)
        end

    end
end


---@param entity EntityHandle 
function Shapeshift.CreateAppearanceOverrideIfHasNone(entity)

    -- usually this component never exists. AAE creates one too
    if (not entity.AppearanceOverride) then
        entity:CreateComponent("AppearanceOverride")
    end
    
end


---@param entity EntityHandle 
---@return table  - visuals
function Shapeshift.GetAllVisuals(entity)

    local ao = Helper.GetPropertyOrDefault(entity, "AppearanceOverride", nil)

    if ao then
        return ao.Visual.Visuals
    else
        return {}
    end
    
end


---@param entity EntityHandle 
function Shapeshift.MakeEditable(entity)

    if Shapeshift.IsShapeshifted(entity) then
        -- Eralyne figured out that type has to be 2 for changes to be visible.
        -- We do not know why
        entity.GameObjectVisual.Type = 2

    end
end


-- in case this fucks with other shit
---@param entity EntityHandle 
---@param delay number|nil -- in ms
function Shapeshift.RevertEditability(entity, delay)

    local function func()

        if Shapeshift.IsShapeshifted(entity) then

            entity:Replicate("AppearanceOverride")
            entity:Replicate("GameObjectVisual") 
    
            Ext.Timer.WaitFor(100, function()
                entity.GameObjectVisual.Type = 4
            end)
        end
        
    end

    Helper.OptionalDelay(func, delay)

end


---@param entity EntityHandle 
function Shapeshift.RemoveCustomVisualOvirride(entity, visual)

    Shapeshift.CreateAppearanceOverrideIfHasNone(entity)

    local visuals = {}

    for _, entry in pairs(entity.AppearanceOverride.Visual.Visuals) do
        if not (entry == visual) then
            table.insert(visuals,entry)
        end
    end

    entity.AppearanceOverride.Visual.Visuals = visuals

end


---@param entity EntityHandle 
function Shapeshift.AddCustomVisualOverride(entity, visual)

    Shapeshift.CreateAppearanceOverrideIfHasNone(entity)

    Ext.Timer.WaitFor(100, function ()
        
        local visuals = {}

        for _, entry in pairs(entity.AppearanceOverride.Visual.Visuals) do
            print("inserting ", entry)
            table.insert(visuals,entry)
        end

        print("inserting new entry", visual)
        table.insert(visuals, visual)
        entity.AppearanceOverride.Visual.Visuals = visuals
        
    end)
end
