local TOOL = {}
TOOL.Base = "base_brush"
TOOL.Description = "Hide and Seek only: Turns Stuck Prevention on for players inside this object."
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(125,125,125,255)
TOOL.TextureText = "No Clip"
--------------------------------------------------------------------------------
function TOOL:EntSetup( ent )
    ent:SetSolidFlags(FSOLID_CUSTOMBOXTEST)

    if SERVER then
        ent:SetTrigger(GAMEMODE.FolderName == "hideandseek")
        return
    end

    local origin = self:GetOrigin()
    local min = Vector()
    local max = Vector()

    for k, point in pairs(self.points) do
        local lp = point - origin
        min.x = math.min(min.x, lp.x)
        min.y = math.min(min.y, lp.y)
        min.z = math.min(min.z, lp.z)
        max.x = math.max(max.x, lp.x)
        max.y = math.max(max.y, lp.y)
        max.z = math.max(max.z, lp.z)
    end

    ent:SetRenderBounds(min, max)
end

function TOOL:EntStartTouch(ent)
end

function TOOL:EntTouch(ent)
    if not IsValid(ent) or not ent:IsPlayer() or ent:Team() == TEAM_SPECTATOR or ent:GetCollisionGroup() == COLLISION_GROUP_WEAPON then return end

    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent:SetColor(ColorAlpha(ent:GetColor(), 235))
end

function TOOL:EntEndTouch(ent)
    ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    ent:SetRenderMode(RENDERMODE_NORMAL)
    ent:SetColor(ColorAlpha(ent:GetColor(), 255))
end

function TOOL:EntShouldCollide(ent)
    return false
end

local mat_forcefield = Material("effects/combineshield/comshieldwall")
local mat_color = Vector(0, 0, 0)
local vector_one = Vector(1, 1, 1)

function TOOL:EntDraw(ent)
    self:BuildMesh()

    local sine = math.abs(math.sin(CurTime()))

    mat_color.x = sine
    mat_color.y = sine
    mat_color.z = sine

    mat_forcefield:SetVector("$color", mat_color)
    render.SetMaterial(mat_forcefield)

    for i = 1, 4 do
        self.render_mesh:Draw()
    end

    mat_forcefield:SetVector("$color", vector_one)
end

return MapPatcher.RegisterTool(TOOL)