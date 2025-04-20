-- I don't think synchronisation is necessary here as these should all be server side changes?
-- Aahz easydye will use them. FocusCore also has them

-- TODO - this is currently indepenadant
-- make sure corresponding spells trigger varsChanges

-- If anything fails, register them in BootStrap instead

-- CONSTRUCTOR
--------------------------------------------------------------
SexUserVars = {}

local settings = {
      Server = true, 
      Client = true, 
      SyncToClient = true, 
      SyncToServer = true,
      SyncOnWrite = true,
      WriteableOnClient = true,
      WriteableOnServer = true
      }

-- TODO - these have to be set to a default
Ext.Vars.RegisterUserVariable("BG3SX_OutOfSexGenital", settings)
Ext.Vars.RegisterUserVariable("BG3SX_SexGenital", settings)
Ext.Vars.RegisterUserVariable("BG3SX_AutoSexGenital", settings)
Ext.Vars.RegisterUserVariable("BG3SX_NPCClothes", settings)
Ext.Vars.RegisterUserVariable("BG3SX_AllowStripping", settings)
Ext.Vars.RegisterUserVariable("BG3SX_IsInvisible", settings)

-- To allow modders to choose certain "sex visuals" for their modded
-- characters (like fresh withers)
-- They are set in the VisualResource and will be exchanged on sex start
-- TODO - not implemented yet
Ext.Vars.RegisterUserVariable("BG3SX_SexVisuals",  settings)


-- _P("[BG3SX - SEXUSERVARS] Registered AutoErection")

---@param type string - either "BG3SX_OutOfSexGenital" or "BG3SX_SexGenital"
---@param genital string - uuid
---@param entity EntityHandle - uuid
function SexUserVars.AssignGenital(type, genital, entity)
      if type == "BG3SX_OutOfSexGenital" then
            entity.Vars.BG3SX_OutOfSexGenital = genital
      elseif type == "BG3SX_SexGenital" then
            entity.Vars.BG3SX_SexGenital = genital
      else
            _P("Invalid type ", type , " please choose ’OutOfSexGenital’ or ’SexGenital’ ")
      end
end

---@param type string - either "BG3SX_OutOfSexGenital" or "BG3SX_SexGenital"
---@param entity EntityHandle - uuid
---@return string
function SexUserVars.GetGenital(type, entity)

      if type == "BG3SX_OutOfSexGenital" then
            return entity.Vars.BG3SX_OutOfSexGenital
      elseif type == "BG3SX_SexGenital" then
            return entity.Vars.BG3SX_SexGenital
      else
            _P("Invalid type ", type , " please choose ’OutOfSexGenital’ or ’SexGenital’ ")
      end
end


---@param autoErection boolean
---@param entity EntityHandle - uuid
function SexUserVars.SetAutoSexGenital(autoErection, entity)
      entity.Vars.BG3SX_AutoSexGenital = autoErection
end


---@param entity EntityHandle - uuid
function SexUserVars.GetAutoSexGenital(entity)
    return entity.Vars.BG3SX_AutoSexGenital
end



---@param autoErection boolean
---@param entity EntityHandle - uuid
function SexUserVars.SetNPCClothes(clothes, entity)
      entity.Vars.BG3SX_NPCClothes = clothes
end


---@param entity EntityHandle - uuid
function SexUserVars.GetNPCClothes(entity)
    return entity.Vars.BG3SX_NPCClothes
end



function SexUserVars.SetAllowStripping(value, entity)
      entity.Vars.BG3SX_AllowStripping = value
end


---@param entity EntityHandle - uuid
function SexUserVars.GetAllowStripping(entity)
    return entity.Vars.BG3SX_AllowStripping
end

-- Client or Server
function SexUserVars.IsInvisble(entity) -- Check if invisible
      local val = entity.Vars.BG3SX_IsInvisible
      if val then
            return val -- If Uservars exist return value
      else
            Event.SetupInvisUserVars:SendToServer(entity.Uuid.EntityUuid) -- Else, set them up as false
            return nil
      end
end

if Ext.IsServer() then
      Event.SetupInvisUserVars:SetHandler(function (uuid)
            local entity = Ext.Entity.Get(uuid)
            local isInvis = Osi.IsInvisible(entity)
            SexUserVars.ToggleInvisibility(entity, false)
      end)
end

-- Server only because of Osi usage
function SexUserVars.ToggleInvisibility(entity, val)
      local val = val or nil
      if val == true then
            Osi.SetVisible(entity, 0)
            entity.Vars.BG3SX_IsInvisible = false
            Event.SetInvisible:Broadcast({Uuid = entity.Uuid.EntityUuid, Value = false})
      elseif val == false then
            Osi.SetVisible(entity, 1)
            entity.Vars.BG3SX_IsInvisible = true
            Event.SetInvisible:Broadcast({Uuid = entity.Uuid.EntityUuid, Value = true})
      else
            local isInvis = SexUserVars.IsVisible(entity) -- If exists, we skip using Osi to get it
            if isInvis == nil then
                  isInvis = Osi.IsInvisible(entity)
            end
            if isInvis == true then
                  Osi.SetVisible(entity, 0)
                  entity.Vars.BG3SX_IsInvisible = false
                  Event.SetInvisible:Broadcast({Uuid = entity.Uuid.EntityUuid, Value = false})
            elseif isInvis == false then
                  Osi.SetVisible(entity, 1)
                  entity.Vars.BG3SX_IsInvisible = true
                  Event.SetInvisible:Broadcast({Uuid = entity.Uuid.EntityUuid, Value = true})
            end
      end
end

if Ext.IsServer() then
      Event.ToggleInvisibility:SetHandler(function (payload)
            local entity = Ext.Entity.Get(payload.Uuid)
            SexUserVars.ToggleInvisibility(entity, payload.Value)
      end)
end