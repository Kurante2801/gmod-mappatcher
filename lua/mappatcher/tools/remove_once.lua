local TOOL = {}
TOOL.Base = "base_brush"
TOOL.Description = "Removes any entities that touches this brush when this brush spawns."
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(150, 0, 0, 200)
TOOL.TextureText = "Remove Once"

function TOOL:EntSetup(ent)
    ent:SetSolidFlags(FSOLID_CUSTOMBOXTEST)
    if SERVER then
        ent:SetTrigger(true)
        self.SpawnTime = CurTime()
    end
end

function TOOL:EntStartTouch(ent)
    if ent.MapPatcherObject or CurTime() - self.SpawnTime > 1 then return end
    SafeRemoveEntity(ent)
end

function TOOL:EntShouldCollide(ent)
    return false
end
--------------------------------------------------------------------------------
return MapPatcher.RegisterTool(TOOL)