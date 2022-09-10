local TOOL = {}
TOOL.Base = "base_brush"
TOOL.Description = "Kill players on touch."
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(255,0,0,200)
TOOL.TextureText = "#mappatcher.tools.kill.title"
--------------------------------------------------------------------------------
function TOOL:EntSetup( ent )
    ent:SetSolidFlags( FSOLID_CUSTOMBOXTEST )
    if SERVER then ent:SetTrigger( true ) end
end

function TOOL:EntStartTouch( ent )
    if not ent:IsPlayer() then return end
    ent:Kill()

    -- Hide and Seek: Turn to seeker on death
    if GAMEMODE.FolderName == "hideandseek" then
        if not GAMEMODE.SeekerBlinded and GAMEMODE.RoundState == ROUND_ACTIVE then
            ent:SetTeam(TEAM_SEEK)
            GAMEMODE:RoundCheck()
        end

        timer.Simple(5, function()
            if IsValid(ent) and not ent:Alive() then
                ent:Spawn()
            end
        end)
    end
end

function TOOL:EntShouldCollide( ent )
    return false
end
--------------------------------------------------------------------------------
return MapPatcher.RegisterTool(TOOL)