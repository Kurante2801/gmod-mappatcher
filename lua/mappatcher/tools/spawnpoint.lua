local TOOL = {}

TOOL.Base = "tp_target"
TOOL.Description = "Replaces map's spawn points with MapPatcher's spawnpoint. You must add a lot of spawn points otherwise players will spawn in the few you've added (since it REPLACES map's spawns)."

--------------------------------------------------------------------------------
TOOL.TextureColor = Color(0,200,25,150)
TOOL.TextureText = "Spawn Point"

--------------------------------------------------------------------------------
function TOOL:SetupObjectPanel( panel )
end

function TOOL.DataFunction(data, tbl)
    tbl.point = data.point
    tbl.ang = data.ang

    return tbl
end

function TOOL:ToString( )
    if getmetatable(self) == self then
        return "[class] " .. self.ClassName
    end
    return "["..self.ID.."] "..self.ClassName
end

--------------------------------------------------------------------------------
if not SERVER then
    return MapPatcher.RegisterTool(TOOL)
end

function TOOL:UpdateEntity()
    local entity = self.entity

    if IsValid(entity) then
        entity:Remove()
    end

    entity = ents.Create("info_player_terrorist")
    entity:Spawn()
    entity:SetPos(self:GetOrigin())
    entity:SetAngles(Angle(0, self.ang, 0))

    print(entity)
    self.entity = entity
end

function TOOL:Initialize()
    if not self:IsObject() then return end
    self:UpdateEntity()
end

function TOOL:PostCleanupMap()
    self:UpdateEntity()
end

hook.Add("PlayerSelectSpawn", "MapPatcher", function(ply)
    local spawns = {}

    for _, object in ipairs(MapPatcher.Objects) do
        if object.ClassName == "spawnpoint" then
            print(object.entity)
            table.insert(spawns, object.entity)
        end
    end
    if #spawns == 0 then return end

    local fallback = spawns[math.random(#spawns)]
    local selected = fallback
    -- Before spawning the player, we'll attempt to use an empty spawn point
    while not GAMEMODE:IsSpawnpointSuitable(ply, selected, false) do
        -- We tested all spawn points, use fallback
        if #spawns == 0 then
            return fallback
        end

        selected = table.remove(spawns, math.random(#spawns))
    end

    return selected
end)

return MapPatcher.RegisterTool(TOOL)
