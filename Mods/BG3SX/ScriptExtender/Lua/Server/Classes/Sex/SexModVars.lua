-- If I don't define this, the console yells at me
ModuleUUID = "df8b9877-5662-4411-9d08-9ee2ec4d8d9e" 


-- USers can set whether they want to "unlock" all animations
-- or only use "genital based" ones
-- This means that 2 characters with penises will have accesss
-- to the "lesbian" animations like "grinding", or "eating pussy" 


Ext.Vars.RegisterModVariable(ModuleUUID, "ShowAllAnimations", {
    Server = true, Client = true, SyncToClient = true
})


local vars = Ext.Vars.GetModVariables(ModuleUUID)

if not vars.ShowAllAnimations then
    print("ShowAllAnimations mod variable not initialized yet")
    print("setting it to default value = false")
    vars.ShowAllAnimations = "false"
end

Ext.Log.Print("ShowAllAnimations")
Ext.Log.Print(vars.ShowAllAnimations)
Ext.Log.Print("End ShowAllAnimations")


Ext.Vars.SyncModVariables(ModuleUUID)
