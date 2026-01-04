-- NOsi functions are Osi function workarounds via ScriptExtender
NOsi = {}
NOsi.__index = NOsi


------------------------------------------------------------------------
-- Teleport
------------------------------------------------------------------------


---@param character string -- uuid of an entity
---@param character2 string -- uuid of an entity to "teleport to"
function NOsi.TeleportTo(character, character2)

        -- print("Calling NOsi.TeleportTo")

    if Ext.IsServer() then
        Debug.Print("NOsi.TeleportTo is not available on the Server")
        return
    else
        local entity = Ext.Entity.Get(character)
        local entity2 = Ext.Entity.Get(character2)
        if not entity then
                Debug.Print("Character " .. character .. " is not an entity")
                return
        elseif not entity2 then
                Debug.Print("Character " .. character2 .. " is not an entity")
                return
        else
                -- print("Transforming")
                local targetposition = entity2.Transform.Transform.Translate
                entity.Transform.Transform.Translate = targetposition
                entity.Visual.Visual:SetWorldTranslate(targetposition)
                Camera:SnapCameraTo(entity)
        end
    end 
end

---@param character string -- uuid of an entity
---@param position table   -- table of {x,y,z} 
function NOsi.TeleportToPosition(character, position)

        -- print("teleporting ", character ," to position ")
        -- _D(position)

    if Ext.IsServer() then
        Debug.Print("NOsi.TeleportToPosition is not available on the Server")
        return
    else
        local entity = Ext.Entity.Get(character)
        if not entity then
                Debug.Print("Character" .. character .. " is not an entity")
                return
        else
                entity.Transform.Transform.Translate = position
                entity.Visual.Visual:SetWorldTranslate(position)
                Camera:SnapCameraTo(entity)
        end
    end 
end


------------------------------------------------------------------------
-- Rotate
------------------------------------------------------------------------

-- use a helper object and Osi to make an entity rotate
---@param uuid string
---@return helper uuid - Helper object that the entity can later look towards with Osi.SteerTo
function Entity:SaveEntityRotation(uuid)
    local entityPosition = {}
    entityPosition.x,entityPosition.y,entityPosition.z = Osi.GetPosition(uuid)
    local entityRotation = {}
    entityRotation.x,entityRotation.y,entityRotation.z = Osi.GetRotation(uuid)
    local entityDegree = Math.DegreeToRadian(entityRotation.y)
    local distanceAwayFromEntity = 1 -- Can be changed
    local x = entityPosition.x + (distanceAwayFromEntity * math.cos(entityDegree))
    local y = entityPosition.y + (distanceAwayFromEntity * math.sin(entityDegree))
    local z = entityPosition.z

    -- Creates and returns the helper object spawned at a distance based on entity rotation to store it to later steer towards
    local helper = Osi.CreateAt("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", x, y, z, 0, 0, "")
    return helper
end

-- Finds the angle degree of an entity based on position difference to a target
---@param entity string - The entities uuid
---@param target string - The targets uuid
function Entity:FindAngleToTarget(entity, target)
        local entityPos = {}
        local targetPos = {}
        entityPos.y, entityPos.x,entityPos.z = Osi.GetPosition(entity)
        targetPos.y, targetPos.x,targetPos.z = Osi.GetPosition(target)
        local dif = {
                y = entityPos.y - targetPos.y,
                x = entityPos.x - targetPos.x,
                z = entityPos.z - targetPos.z,  
        }
        local degree = math.atan(dif.y, dif.x)
        return degree
end

---@param character string -- uuid of an entity
---@param position number   -- number (radian)
function NOsi.SetRotate(character, position)
    if Ext.IsServer() then
        Debug.Print("NOsi.RotateToPosition is not available on the Server")
        return
    else
        local entity = Ext.Entity.Get(character)
        if not entity then
                Debug.Print("Character" .. character .. " is not an entity")
                return
        else
                entity.Steering.TargetRotation = position
        end
    end 
end

-- Don't touch, this works
function NOsi.RotateByDegree(character, degree)
        if degree and type(degree) == "string" then
                degree = tonumber(degree)
        elseif degree and type(degree) == "number" then
                -- Do nothing           
        elseif not degree or (type(degree) ~= "string" and type(degree) ~= "number") then
                        Debug.Print("Not a valid number")
                return 
        end

        if Ext.IsServer() then
                Debug.Print("NOsi.RotateToPosition is not available on the Server")
                return
        elseif Ext.IsClient() then
                local entity = Ext.Entity.Get(character)
                if not entity then
                        Debug.Print("Character" .. character .. " is not an entity")
                        return
                else
                        local currentRotation = entity.Steering.TargetRotation
                        local radian = Math.DegreeToRadian(degree)
                        local newRotation = currentRotation + radian
                        entity.Steering.TargetRotation = newRotation
                end
        end
end             

function NOsi.RotateToPosition(character, position)

        if Ext.IsServer() then
                Debug.Print("NOsi.RotateToPosition is not available on the Server")
                return
        elseif Ext.IsClient() then
                local entity = Ext.Entity.Get(character)
                if not entity then
                        Debug.Print("Character" .. character .. " is not an entity")
                        return
                elseif not position then
                        Debug.Print("Not a valid position to rotate towards")
                        return
                else
                        local entityPos = entity.Transform.Transform.Translate
                        local targetPos = position
                        local dif = {
                                y = entityPos[1] - targetPos[1],
                                x = entityPos[2] - targetPos[2],
                                z = entityPos[3] - targetPos[3],  
                        }
                        local angle = Ext.Math.Atan2(dif.y, dif.x)
                        local degree = math.deg(angle)

                        local currentRotation = entity.Steering.TargetRotation
                        local newRotation = currentRotation + degree
                        local newRotRadian = Math.DegreeToRadian(newRotation)
                        entity.Steering.TargetRotation = newRotRadian
                end
        end 
end

function NOsi.RotateTo(character, character2)
        if Ext.IsServer() then
                Debug.Print("NOsi.RotateToPosition is not available on the Server")
                return
        elseif Ext.IsClient() then

                local entity = Ext.Entity.Get(character)
                local entity2 = Ext.Entity.Get(character2)
                if not entity then
                        Debug.Print("Character" .. character .. " is not an entity")
                        return
                elseif not entity2 then
                        Debug.Print("Character" .. character2 .. " is not an entity")
                        return
                else
                        local entityPos = entity.Transform.Transform.Translate
                        local targetPos = entity2.Transform.Transform.Translate
                        local currentRotation = entity.Transform.Transform.RotationQuat
                        local dif = {
                                y = entityPos[1] - targetPos[1],
                                x = entityPos[2] - targetPos[2],
                                z = entityPos[3] - targetPos[3],  
                        }
                        local degree = math.atan(dif.y, dif.x)
                        --local newRotation = {currentRotation[1], degree, currentRotation[3], currentRotation[4]}
                        --entity.Transform.Transform.RotationQuat = newRotation
                        --entity.Visual.Visual:SetWorldRotate(newRotation)

                        local function checkIfVisualExists(entity)
                                if entity.Visual then
                                        if entity.Visual.Visual then
                                                return true
                                        else
                                                return false
                                        end
                                else
                                        return false
                                end
                        end
                        local function recurseCheckVisualAndRotate(entity)
                                Ext.Timer.WaitFor(50, function()
                                        if checkIfVisualExists then
                                                entity.Visual.Visual:SetWorldRotate(entity2.Transform.Transform.RotationQuat)
                                                return true
                                        end
                                        return recurseCheckVisualAndRotate(entity)
                                end)
                        end

                        if entity.Steering then
                                entity.Steering.TargetRotation = degree

                        else
                                recurseCheckVisualAndRotate(entity) -- Recursive check until visual exists so we can rotate
                        end
                end
        end
end

function NOsi.CopyRotation(character, character2)
        if Ext.IsServer() then
                Debug.Print("NOsi.RotateToPosition is not available on the Server")
                return
        elseif Ext.IsClient() then
                local entity = Ext.Entity.Get(character)
                local entity2 = Ext.Entity.Get(character2)
                if not entity then
                        Debug.Print("Character" .. character .. " is not an entity")
                        return
                elseif not entity2 then
                        Debug.Print("Character" .. character2 .. " is not an entity")
                        return
                else
                        local entitySteeringRotation = entity.Steering.TargetRotation
                        local entity2SteeringRotation = entity2.Steering.TargetRotation
                        entity.Steering.TargetRotation = entity2SteeringRotation
                end
        end
end

-- use a helper object and Osi to make an entity rotate
---@param entity uuid
---@param helper uuid - helper object 
function Entity:RotateEntity(uuid, helper)
    Osi.SteerTo(uuid, helper, 1)
end


Lunisole = {}

function Lunisole.Rotate(character, location)
    local char = Ext.Entity.Get(character)
    local charTransform = char.Transform.Transform
    local charx = charTransform.Translate[1]
    local chary = charTransform.Translate[3]
    local vecx = charx - location[1]
    local vecy = chary - location[3]
    local RadToLookAt = Ext.Math.Atan2(vecx,vecy)
    if char.Steering then
        char.Steering.TargetRotation = RadToLookAt
    elseif char.Visual then
        local yaw = RadToLookAt

        -- Convert yaw (radians) to quaternion (Y axis only)
        local half = yaw * 0.5
        local qx = 0
        local qy = math.sin(half)
        local qz = 0
        local qw = math.cos(half)

        char.Visual.Visual:SetWorldRotate({qx, qy, qz, qw})
    else
        Debug.Print("Can't rotate Entity " .. char.Uuid.EntityUuid)
    end
end



if Ext.IsClient() then
        Event.RequestTeleport:SetHandler(function (payload)

                local character = payload.character
                local targetPosition = payload.target

                -- print("received teleport request for ", character, " to ", targetPosition)

                if type(targetPosition) == "table" then
                        -- targetPosition is coordinates
                        NOsi.TeleportToPosition(character, targetPosition)
                else
                        -- targetposition is another character
                        NOsi.TeleportTo(character, targetPosition)
                end
        end)


        Event.RequestRotation:SetHandler(function (payload)

                -- print("received rotation request")
                -- _D(payload)

                local character = payload.character
                local radRotationOrEntity = payload.target

                if type(radRotationOrEntity) == "number" then -- 81
                        -- targetPosition is coordinates
                        NOsi.SetRotate(character, radRotationOrEntity)
                elseif type(radRotationOrEntity) == "table" then -- x,y,z

                        --NOsi.RotateToPosition(character, targetRotation)
                        Lunisole.Rotate(character, radRotationOrEntity)
                else
                        -- targetposition is another character
                        NOsi.RotateTo(character, radRotationOrEntity)
                end
        end)
end

