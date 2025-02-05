local TOOL = {}

TOOL.Base = "base_brush"
TOOL.Description = "A combination of various other tools + extra. Probably something I should have done initially."
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(155,155,155,200)
TOOL.TextureText = "Custom"
--------------------------------------------------------------------------------

function TOOL:WriteToBuffer( buffer )
    TOOL:GetBase().WriteToBuffer( self, buffer )
    buffer:WriteBool(self.clip_bullet)

    buffer:WriteUInt8(self.color.r)
    buffer:WriteUInt8(self.color.g)
    buffer:WriteUInt8(self.color.b)
    buffer:WriteUInt8(self.color.a)

    buffer:WriteBool(self.clip_player)
    buffer:WriteBool(self.clip_prop)
    buffer:WriteBool(self.clip_other)
    buffer:WriteString(self.group)
    buffer:WriteBool(self.group_invert)
    buffer:WriteBool(self.group_player)
    buffer:WriteString(self.texture)
end

function TOOL:ReadFromBuffer( buffer, len )
    TOOL:GetBase().ReadFromBuffer(self, buffer)
    self.clip_bullet = buffer:ReadBool()
    self.color = Color(buffer:ReadUInt8(), buffer:ReadUInt8(), buffer:ReadUInt8(), buffer:ReadUInt8())
    self.clip_player = buffer:ReadBool()
    self.clip_prop = buffer:ReadBool()
    self.clip_other = buffer:ReadBool()
    self.group = buffer:ReadString()
    self.group_invert = buffer:ReadBool()
    self.group_player = buffer:ReadBool()
    self.texture = buffer:ReadString()
end

function TOOL.DataFunction(data, tbl)
    tbl = TOOL:GetBase().DataFunction(data, tbl)

    tbl.clip_bullet = data.clip_bullet
    tbl.color = data.color
    tbl.clip_prop = data.clip_prop
    tbl.clip_other = data.clip_other
    tbl.group = data.group
    tbl.group_invert = data.group_invert
    tbl.clip_player = data.clip_player
    tbl.texture = data.texture

    return tbl
end

function TOOL:SetupObjectPanel( panel )
    local DLabel = vgui.Create( "DLabel", panel )
    DLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    DLabel:SetPos( 10, 10 )
    DLabel:SetText( "Name:" )

    local TextEntry = vgui.Create( "DTextEntry", panel ) 
    TextEntry:SetPos( 50, 10 )
    TextEntry:SetSize( 100, 20 )
    TextEntry:SetText( self.name )
    TextEntry.OnChange = function( text_entry )
        self.name = text_entry:GetValue()
    end
end

function TOOL:ObjectCreated()
    TOOL:GetBase().ObjectCreated(self)
    self.clip_player = true
    self.clip_prop = false
    self.clip_bullet = false
    self.clip_other = false
    self.group = "everyone"
    self.group_invert = false
    self.texture = ""
    self.color = Color(255,255,255)
end

--------------------------------------------------------------------------------
function TOOL:EntSetup( ent )
    ent:SetSolidFlags( FSOLID_CUSTOMBOXTEST + FSOLID_CUSTOMRAYTEST )

    if CLIENT then
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

        ent:SetRenderBounds( min, max )
        

        if self.texture == "forcefield" then
            ent.snd_forcefield_loop = "mappatcher_forcefield_loop_"..(ent:EntIndex())
            sound.Add( {
                name = "mappatcher_forcefield_loop_"..(ent:EntIndex()),
                channel = CHAN_AUTO,
                volume = 0.5,
                level = 55,
                pitch = 100,
                sound = "ambient/energy/force_field_loop1.wav"
            } )
            ent:EmitSound( ent.snd_forcefield_loop )
        end
    end
end

function TOOL:SetupObjectPanel( panel )
    
    -- Clip: Player, Prop, Other Physics Objects, Bullets
    -- Group:
    -- Invert Group:
    -- Texture: Force Field, Stripes, Solid, Invisible
    -- Color:
    local lblClip = vgui.Create( "DLabel", panel )
    lblClip:SetTextColor( Color( 255, 255, 255, 255 ) )
    lblClip:SetPos( 10, 10 )
    lblClip:SetText( "Clip:" )
    
    local cbxClipPlayer = vgui.Create( "DCheckBoxLabel", panel )
    cbxClipPlayer:SetPos( 55, 12 )
    cbxClipPlayer:SetText( "Player" )
    cbxClipPlayer:SetValue( self.clip_player )
    cbxClipPlayer:SizeToContents()
    cbxClipPlayer.OnChange = function( panel, val )
        self.clip_player = val
    end

    local cbxClipProps = vgui.Create( "DCheckBoxLabel", panel )
    cbxClipProps:SetPos( 120, 12 )
    cbxClipProps:SetText( "Props" )
    cbxClipProps:SetValue( self.clip_prop )
    cbxClipProps:SizeToContents()
    cbxClipProps.OnChange = function( panel, val )
        self.clip_prop = val
    end

    local lblGroup = vgui.Create( "DLabel", panel )
    lblGroup:SetTextColor( Color( 255, 255, 255, 255 ) )
    lblGroup:SetPos( 10, 35 )
    lblGroup:SetText( "Block:" )


    local cmbGroup = vgui.Create( "DComboBox", panel )
    cmbGroup:SetPos( 55, 35 )
    cmbGroup:SetSize( 110, 20 )
    for key, group in pairs(MapPatcher.Groups.GetGroups()) do
        cmbGroup:AddChoice( MapPatcher.Groups.GetName(group), group, self.group == group)
    end
    cmbGroup.OnSelect = function( panel, index, value, data )
        self.group = data
    end


    local cbxGroupInvert = vgui.Create( "DCheckBoxLabel", panel )
    cbxGroupInvert:SetPos( 170, 37 )
    cbxGroupInvert:SetText( "Invert" )
    cbxGroupInvert:SetValue( self.group_invert )
    cbxGroupInvert:SizeToContents()

    cbxGroupInvert.OnChange = function( panel, val )
        self.group_invert = val
    end

    local lblTexture = vgui.Create( "DLabel", panel )
    lblTexture:SetTextColor( Color( 255, 255, 255, 255 ) )
    lblTexture:SetPos( 10, 60 )
    lblTexture:SetText( "Texture:" )


    local cmbGroup = vgui.Create( "DComboBox", panel )
    cmbGroup:SetPos( 55, 60 )
    cmbGroup:SetSize( 110, 20 )
    cmbGroup:AddChoice( "Invisible", "", self.texture == "")
    cmbGroup:AddChoice( "Forcefield", "forcefield", self.texture == "forcefield")
    cmbGroup:AddChoice( "Solid", "solid", self.texture == "solid")
    cmbGroup.OnSelect = function( panel, index, value, data )
        self.texture = data
    end



    local lblColor = vgui.Create( "DLabel", panel )
    lblColor:SetTextColor( Color( 255, 255, 255, 255 ) )
    lblColor:SetPos( 10, 85 )
    lblColor:SetText( "Color:" )

    local colorPicker = vgui.Create( "DColorMixer", panel )
    colorPicker:SetPos( 55, 85 )
    colorPicker:SetSize( 300, 200 )
    colorPicker:SetPalette( true )
    colorPicker:SetAlphaBar( true )
    colorPicker:SetWangs( true )
    colorPicker:SetColor( self.color )
    colorPicker.ValueChanged = function( panel, col )
        self.color = col
    end
end


function TOOL:EntRemove( ent )
    if CLIENT then
        if ent.snd_forcefield_loop then
            ent:StopSound( ent.snd_forcefield_loop )
        end
    end
end

function TOOL:EntStartTouch( ent )
end

function TOOL:EntShouldCollide( ent )

    if self.clip_player and ent:IsPlayer() then
        if not self.group_invert then
            return MapPatcher.Groups.Check( self.group, ent )
        else
            return not MapPatcher.Groups.Check( self.group, ent )
        end
    elseif self.clip_prop and ent:GetMoveType() == MOVETYPE_VPHYSICS then
        return true
    end

    return false
    
end

local mat_forcefield = Material("effects/combineshield/comshieldwall2")
local mat_solid = Material( "color" )
function TOOL:EntDraw( ent )
    if self.texture == "forcefield" then
        self:BuildMesh()
        render.SetMaterial( mat_forcefield )

        for i=1, 8 do
            self.render_mesh:Draw()
        end
    elseif self.texture == "solid" then
        self:BuildMesh()
        render.SetMaterial( mat_solid )
        self.render_mesh:Draw()
    end
end

local hit_sounds = {}
for i=1, 4 do
    hit_sounds[#hit_sounds + 1] = Sound("ambient/energy/spark"..i..".wav")
end

function TOOL:EntImpactTrace( ent, trace, dmgtype, customimpactname )
    if self.texture == "forcefield" then
        if IsFirstTimePredicted() then
            EmitSound( hit_sounds[math.random(1,#hit_sounds)], trace.HitPos, ent:EntIndex(), CHAN_AUTO, 1, 80, 0, 100 )
        end

        local effectdata = EffectData()
        effectdata:SetOrigin( trace.HitPos )
        effectdata:SetNormal( trace.HitNormal )
        util.Effect( "AR2Impact", effectdata )
        return true
    end
end
--------------------------------------------------------------------------------
return MapPatcher.RegisterTool(TOOL)