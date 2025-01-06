-- I don't think synchronisation is necessary here as these should all be server side changes?
-- Aahz easydye will use them. FocusCore also has them

-- TODO - this is currently indepenadant
-- make sure corresponding spells trigger varsChanges

-- If anything fails, register them in BootStrap instead

-- CONSTRUCTOR
--------------------------------------------------------------
SexUserVars = {}

-- TODO - these have to be set to a default
Ext.Vars.RegisterUserVariable("BG3SX_OutOfSexGenital", {})
Ext.Vars.RegisterUserVariable("BG3SX_SexGenital", {})
Ext.Vars.RegisterUserVariable("BG3SX_AutoSexGenital", {})
Ext.Vars.RegisterUserVariable("BG3SX_NPCClothes", {})
Ext.Vars.RegisterUserVariable("BG3SX_BlockStripping", {})


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



function SexUserVars.SetBlockStripping(value, entity)
      entity.Vars.BG3SX_BlockStripping = value
end


---@param entity EntityHandle - uuid
function SexUserVars.GetBlockStripping(entity)
    return entity.Vars.BG3SX_BlockStripping
end

