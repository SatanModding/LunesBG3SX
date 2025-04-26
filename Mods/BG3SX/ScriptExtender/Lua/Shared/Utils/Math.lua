function Math.DegreeToRadian(deg)
    return deg * (math.pi/180)
end
function Math.RadianToDegree(rad)
    return rad * (180/math.pi)
end




-- Function to calculate the squared distance between two points in 3D space
function Math.distance_squared_3d(x1, y1, z1, x2, y2, z2)
    return (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2
end


-- Function to calculate the squared distance between two points in the x direction
function Math.distance_squared_x(x1, x2)
    return (x2 - x1)^2
end


function Math.distance_squared_x_y(x1,y1, x2, y2)
    return (x2 - x1)^2 + (y2 - y1)^2
end


-- Function to check if point B is within distance of point A
function Math.is_within_distance_3d(entityA, entityB, max_distance)
    local x1, z1, y1 = table.unpack(entityA.Transform.Transform.Translate)
    local x2, z2, y2 = table.unpack(entityB.Transform.Transform.Translate)
    -- Calculate the squared distance between the points to avoid calculating the square root
    local distance_sq = Math.distance_squared_3d(x1, y1, z1, x2, y2, z2)
    local max_distance_sq = max_distance^2
    
    -- Check if the squared distance is less than or equal to the squared maximum distance
    return distance_sq <= max_distance_sq
end



-- Function to check if point B is within distance of point A
function Math.is_within_distance_x(entityA, entityB, max_distance)
    local x1, z1, y1 = table.unpack(entityA.Transform.Transform.Translate)
    local x2, z2, y2 = table.unpack(entityB.Transform.Transform.Translate)

    -- Calculate the squared distance between the points to avoid calculating the square root
    local distance_sq = Math.distance_squared_x(x1, x2)
    local max_distance_sq = max_distance^2
    
    -- Check if the squared distance is less than or equal to the squared maximum distance
    return distance_sq <= max_distance_sq
end


function Math.is_within_distance_x_y(entityA, entityB, max_distance)
    local x1, z1, y1 = table.unpack(entityA.Transform.Transform.Translate)
    local x2, z2, y2 = table.unpack(entityB.Transform.Transform.Translate)

    -- Calculate the squared distance between the points to avoid calculating the square root
    local distance_sq = Math.distance_squared_x_y(x1,y1, x2, y2)
    local max_distance_sq = max_distance^2
    
    -- Check if the squared distance is less than or equal to the squared maximum distance
    return distance_sq <= max_distance_sq
end



-- Function to check if point B is within distance of point A
function Math.is_farther_than_distance_3d(entityA, entityB, min_distance)
    local x1, z1, y1 = table.unpack(entityA.Transform.Transform.Translate)
    local x2, z2, y2 = table.unpack(entityB.Transform.Transform.Translate)

    -- Calculate the squared distance between the points
    local distance_sq = Math.distance_squared_3d(x1, y1, z1, x2, y2, z2)
    local min_distance_sq = min_distance^2

    -- Check if the squared distance is greater than the squared minimum distance
    return distance_sq > min_distance_sq
end


-- Function to check if point B is within distance of point A
function Math.is_farther_than_distance_x(entityA, entityB, min_distance)
    local x1, z1, y1 = table.unpack(entityA.Transform.Transform.Translate)
    local x2, z2, y2 = table.unpack(entityB.Transform.Transform.Translate)

    -- Calculate the squared distance between the points
    local distance_sq = Math.distance_squared_x(x1,x2)
    local min_distance_sq = min_distance^2

    -- Check if the squared distance is greater than the squared minimum distance
    return distance_sq > min_distance_sq
end



function Math.is_farther_than_distance_x_y(entityA, entityB, min_distance)
    local x1, z1, y1 = table.unpack(entityA.Transform.Transform.Translate)
    local x2, z2, y2 = table.unpack(entityB.Transform.Transform.Translate)

    -- Calculate the squared distance between the points
    local distance_sq = Math.distance_squared_x_y(x1,y1, x2, y2)
    local min_distance_sq = min_distance^2

    -- Check if the squared distance is greater than the squared minimum distance
    return distance_sq > min_distance_sq
end



function Math.is_within_tolerance_x_y(entityA, entityB, max_distance, y_tolerance_up, y_tolerance_down)
    
    -- stupid game engines having different y and z coordinates
    local x1, z1, y1 = table.unpack(entityA.Transform.Transform.Translate)
    local x2, z2, y2 = table.unpack(entityB.Transform.Transform.Translate)

    -- Check if x is within the max_distance
    local distance_sq_x = (x2 - x1)^2
    local max_distance_sq = max_distance^2

    -- Check if y is within the tolerance range
    local is_y_within_tolerance = (y2 <= y1 + y_tolerance_up) and (y2 >= y1 - y_tolerance_down)

    return distance_sq_x <= max_distance_sq and is_y_within_tolerance
end


-- Norb functions 
local function GetDistanceFC(object, position2, ignoreHeight)
    local object_loc = {}
    object_loc.x, object_loc.y, object_loc.z = Osi.GetPosition(object)
    ignoreHeight = ignoreHeight == nil or ignoreHeight
    return math.sqrt((object_loc.x - position2.x)^2
                  + ((ignoreHeight and 0) or (object_loc.y - position2.y)^2)
                  + (object_loc.z - position2.z)^2)
end

local function GetDistanceFCS(object, position2)
    local x, y, z = Osi.GetPosition(object)
    return math.sqrt((x - position2.x)^2 + (z - position2.z)^2)
end

local function GetDistanceENT(entity, position2)
    local pos = entity.Transform.Transform.Translate
    return math.sqrt((pos[1] - position2.x)^2 + (pos[3] - position2.z)^2)
end



local function GetDistanceENTENT(entityA, entityB)
    local posA = entityA.Transform.Transform.Translate
    local posB = entityB.Transform.Transform.Translate
    local dx = posA[1] - posB[1]
    local dz = posA[3] - posB[3]
    return dx * dx + dz * dz
end



function Math.IsWithinDistanceBetweenEntities(entityA, entityB, maxDistance)
    local posA = entityA.Transform.Transform.Translate
    local posB = entityB.Transform.Transform.Translate

    local dx = posA[1] - posB[1]  -- x
    local dz = posA[3] - posB[3]  -- z
    local distanceSquared = dx * dx + dz * dz

    return distanceSquared <= (maxDistance * maxDistance)
end
