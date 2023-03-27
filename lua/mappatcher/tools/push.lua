local TOOL = {}
TOOL.Base = "base_brush"
TOOL.Description = "Pushes props and players."
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(0, 255, 0, 75)
TOOL.TextureText = "Push"
--------------------------------------------------------------------------------
function TOOL:ObjectCreated()
    TOOL:GetBase().ObjectCreated(self)
    self.ang = Angle(270, 0, 0)
    self.force = 5
    self.visible = true
    self.props = true
    self.players = true
end

function TOOL.DataFunction(data, tbl)
    tbl = TOOL:GetBase().DataFunction(data, tbl)
    tbl.ang = data.ang
    tbl.force = data.force
    tbl.visible = data.visible
    tbl.props = data.props
    tbl.players = data.players

    return tbl
end

function TOOL:EntSetup(ent)
    ent:SetSolidFlags(FSOLID_CUSTOMBOXTEST)

    if SERVER then
        ent:SetTrigger(true)
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

function TOOL:EntTouch(ent)
    if ent:IsPlayer() then
        if self.players and ent:Team() ~= TEAM_SPECTATOR then
            ent:SetVelocity(self.ang:Forward() * self.force)
        end
    else
        if self.props and IsValid(ent:GetPhysicsObject()) then
            ent:GetPhysicsObject():AddVelocity(self.ang:Forward() * self.force)
        end
    end
end

function TOOL:EntShouldCollide(ent)
    return false
end
--------------------------------------------------------------------------------
function TOOL:SetupObjectPanel(panel)
    local lblClip = vgui.Create( "DLabel", panel )
    lblClip:SetTextColor( Color( 255, 255, 255, 255 ) )
    lblClip:SetPos( 10, 10 )
    lblClip:SetText( "Push" )

    local cbxClipPlayer = vgui.Create( "DCheckBoxLabel", panel )
    cbxClipPlayer:SetPos( 55, 12 )
    cbxClipPlayer:SetText( "Players" )
    cbxClipPlayer:SetValue( self.players )
    cbxClipPlayer:SizeToContents()
    cbxClipPlayer.OnChange = function( this, val )
        self.players = val
    end

    local cbxClipProps = vgui.Create( "DCheckBoxLabel", panel )
    cbxClipProps:SetPos( 120, 12 )
    cbxClipProps:SetText( "Props" )
    cbxClipProps:SetValue( self.props )
    cbxClipProps:SizeToContents()
    cbxClipProps.OnChange = function( this, val )
        self.props = val
    end

    local DLabel = vgui.Create("DLabel", panel)
    DLabel:SetTextColor( Color(255, 255, 255, 255) )
    DLabel:SetPos(10, 30)
    DLabel:SetText("Angle (P Y R)")
    DLabel:SizeToContents()

    local NumberWangP = vgui.Create("DNumberWang", panel)
    NumberWangP:SetPos(80, 30)
    NumberWangP:SetSize(50, 20)
    NumberWangP:SetMinMax(-360, 360)
    NumberWangP:SetValue(self.ang.p)
    NumberWangP.OnValueChanged = function(this, value)
        self.ang.p = value
    end

    local NumberWangY = vgui.Create("DNumberWang", panel)
    NumberWangY:SetPos(130, 30)
    NumberWangY:SetSize(50, 20)
    NumberWangY:SetMinMax(-360, 360)
    NumberWangY:SetValue(self.ang.y)
    NumberWangY.OnValueChanged = function(this, value)
        self.ang.y = value
    end

    local NumberWangR = vgui.Create("DNumberWang", panel)
    NumberWangR:SetPos(180, 30)
    NumberWangR:SetSize(50, 20)
    NumberWangR:SetMinMax(-360, 360)
    NumberWangR:SetValue(self.ang.r)
    NumberWangR.OnValueChanged = function(this, value)
        self.ang.r = value
    end

    for i = 1, 2 do
        local button = panel:Add("DButton")
        button:SetPos(230 + (i == 1 and 0 or 50), 30)
        button:SetSize(50, 20)
        button:SetText(i == 1 and "UP" or "DOWN")
        button.Value = i == 1 and 270 or 90
        button.DoClick = function(this)
            NumberWangP:SetValue(this.Value)
            NumberWangY:SetValue(0)
            NumberWangR:SetValue(0)
            self.ang = Angle(this.Value, 0, 0)
        end
    end

    DLabel = vgui.Create("DLabel", panel)
    DLabel:SetTextColor( Color(255, 255, 255, 255) )
    DLabel:SetPos(10, 50)
    DLabel:SetText("Force")
    DLabel:SizeToContents()

    local NumberWang = vgui.Create("DNumberWang", panel)
    NumberWang:SetPos(80, 50)
    NumberWang:SetSize(50, 20)
    NumberWang:SetMinMax(0, 2000)
    NumberWang:SetValue(self.force)
    NumberWang.OnValueChanged = function(this, value)
        self.force = value
    end

    cbxClipPlayer = vgui.Create( "DCheckBoxLabel", panel )
    cbxClipPlayer:SetPos( 8, 72 )
    cbxClipPlayer:SetText( "Visible" )
    cbxClipPlayer:SetValue( self.visible )
    cbxClipPlayer:SizeToContents()
    cbxClipPlayer.OnChange = function( this, val )
        self.visible = val
    end
end
--------------------------------------------------------------------------------
local mat_forcefield = Material("effects/combineshield/comshieldwall")
local mat_color = Vector(0, 0, 0)
local vector_one = Vector(1, 1, 1)

function TOOL:EntDraw(ent)
    if not self.visible then return end

    self:BuildMesh()

    local sine = math.abs(math.sin(CurTime()))

    mat_color.y = sine
    mat_color.z = sine

    mat_forcefield:SetVector("$color", mat_color)
    render.SetMaterial(mat_forcefield)

    for i = 1, 4 do
        self.render_mesh:Draw()
    end

    mat_forcefield:SetVector("$color", vector_one)
end

local cyan = Color(0, 255, 255)
local red = Color(255, 0, 0)
function TOOL:EditorRender(selected)
    render.OverrideDepthEnable(false)
    self:GetBase().EditorRender(self, selected)
    local point = self:GetOrigin() + self.ang:Forward() * 36

    render.SetColorMaterial()
    render.DrawLine(self:GetOrigin(), point, COLOR_WHITE, true)
    render.DrawSphere(point, 10, 10, 10, cyan)
    render.DrawSphere(self:GetOrigin(), 5, 10, 10, red)
end
--------------------------------------------------------------------------------
return MapPatcher.RegisterTool(TOOL)