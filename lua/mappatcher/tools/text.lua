local TOOL = {}
--------------------------------------------------------------------------------
local SECONDARY_NONE, SECONDARY_SHADOW, SECONDARY_OUTLINE = 0, 1, 2
--------------------------------------------------------------------------------
TOOL.EditorMenu = true
TOOL.Base = "base_point"
TOOL.Description = "Displays text."
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(0, 150, 255, 150)
TOOL.TextureText = "Text"
TOOL.TextureColorSelected = Color(75, 0, 255, 150)
--------------------------------------------------------------------------------
function TOOL:UpdateEntity()
    local name = string.format("MapPatcher_TextTool_%s%s", self.font, self.size)
    MapPatcher.Fonts3D = MapPatcher.Fonts3D or {}
    if MapPatcher.Fonts3D[name] then return end

    surface.CreateFont(name, {
        font = self.font, size = self.size * 12.5
    })

    MapPatcher.Fonts3D[name] = true
end

function TOOL:Initialize()
    if CLIENT and self:IsObject() then
        self:UpdateEntity()
    end
end

function TOOL:PostCleanupMap()
    if CLIENT and self:IsObject() then
        self:UpdateEntity()
    end
end
--------------------------------------------------------------------------------
function TOOL:PreviewPaint(panel, w, h)
    local x, y = panel:LocalToScreen(0, 0)
    cam.Start3D(Vector(-1.7, -1.7, 1.2), Angle(30, 45, 0), 90, x, y, w, h, -1, 0)
    render.SetMaterial(MapPatcher.GetToolMaterial(self.ClassName))
    render.DrawBox(Vector(), Angle(0, RealTime() * 40, 0), Vector(-1, -1, -1), Vector(1, 1, 1), Color(255, 255, 255), true)
    render.DrawWireframeBox(Vector(), Angle(0, RealTime() * 40, 0), Vector(-1, -1, -1), Vector(1, 1, 1), Color(255, 255, 255), true)
    cam.End3D()
end

function TOOL:ObjectCreated()
    self:GetBase().ObjectCreated(self)
    self.ang = Angle(0, 0, 0)
    self.text = ""
    self.color = Color(255, 255, 255)
    self.font = "Roboto"
    self.size = 16
    self.secondary = SECONDARY_NONE
    self.secondary_value = 1
end

function TOOL:LeftClick(pos, ang, tr)
    self.point = pos

    if tr.Hit then
        tr.HitAngle = tr.HitNormal:Angle()
        local angle = Angle(tr.HitAngle)

        if angle.p >= 260 and angle.p <= 280 then
            -- When hitting the ground, we want the text to be looking towards us
            angle:RotateAroundAxis(tr.HitAngle:Right(), -90)
            angle:RotateAroundAxis(tr.HitAngle:Forward(), self:RoundYaw(ang.y) + 270)
        elseif angle.p >= 80 and angle.p <= 100 then
            -- Same when hitting roof
            angle:RotateAroundAxis(tr.HitAngle:Right(), -90)
            angle:RotateAroundAxis(tr.HitAngle:Forward(), -self:RoundYaw(ang.y) + 270)
        else
            -- When on a wall, text should always be horizontal
            angle:RotateAroundAxis(tr.HitAngle:Right(), -90)
            angle:RotateAroundAxis(tr.HitAngle:Forward(), 90)
        end

        self.ang = angle
    else
        -- When in air, we'll just have the text point towars us completely
        local angle = Angle(ang)
        angle:RotateAroundAxis(angle:Up(), 270)
        angle:RotateAroundAxis(angle:Forward(), 90)
        self.ang = angle
    end
end

-- Only round when pressing CTRL
function TOOL:RoundYaw(yaw)
    if not self.CTRL then
        self.CTRL = input.LookupBinding("+duck", true)
    end

    if self.CTRL and isstring(self.CTRL) then
        self.CTRL = input.GetKeyCode(self.CTRL)
    end

    if self.CTRL and input.IsButtonDown(self.CTRL) then return 45 * math.Round(yaw / 45) end

    return yaw
end

function TOOL:EditorRender(selected)
    render.OverrideDepthEnable(false)
    local w, h = self:TextDraw()
    render.OverrideDepthEnable( true, true )
    w = math.max(16, w * 0.04)
    h = math.max(6, h * 0.04)

    render.SetColorMaterial()

    if selected then
        render.DrawBox(self:GetOrigin(), self:GetAngles(), Vector(-w, -h, 0), Vector(w, h, 2), self.TextureColorSelected, true)
        render.DrawWireframeBox(self:GetOrigin(), self:GetAngles(), Vector(-w, -h, 0), Vector(w, h, 2), Color(255, 255, 255), false)
    else
        render.DrawBox(self:GetOrigin(), self:GetAngles(), Vector(-w, -h, 0), Vector(w, h, 2), self.TextureColor, true)
        render.DrawWireframeBox(self:GetOrigin(), self:GetAngles(), Vector(-w, -h, 0), Vector(w, h, 2), Color(255, 255, 255, 20), false)
    end
end

local color_dark = Color(0, 0, 0, 200)
function TOOL:TextDraw()
    local name = string.format("MapPatcher_TextTool_%s%s", self.font, self.size)
    if not MapPatcher.Fonts3D or not MapPatcher.Fonts3D[name] or self.text == "" then return 0, 0 end

    surface.SetFont(name)
    local w, h = surface.GetTextSize(self.text or "")

    cam.Start3D2D(self:GetOrigin(), self:GetAngles(), 0.08)
    if self.secondary == SECONDARY_SHADOW then
        surface.SetTextColor(color_dark.r, color_dark.g, color_dark.b, color_dark.a)
        surface.SetTextPos(w * -0.5 + self.secondary_value, h * -0.5 + self.secondary_value)
        surface.DrawText(self.text)
    elseif self.secondary == SECONDARY_OUTLINE then
        draw.SimpleTextOutlined(self.text, name, 0, 0, color_dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, self.secondary_value, color_dark)
    end

    surface.SetTextColor(self.color.r, self.color.g, self.color.b, self.color.a)
    surface.SetTextPos(w * -0.5, h * -0.5)
    surface.DrawText(self.text)
    cam.End3D2D()

    return w, h
end

function TOOL:GetOrigin()
    return self.point
end

function TOOL:GetAngles()
    return self.ang
end

function TOOL:IsValid()
    return self.point ~= nil
end

function TOOL:ToString()
    if getmetatable(self) == self then return "[class] " .. self.ClassName end

    return string.format("[%s] %s \"%s\"", self.ID, self.ClassName, self.text or "")
end

function TOOL:SetupObjectPanel(panel)
    local DLabel = vgui.Create( "DLabel", panel )
    DLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    DLabel:SetPos( 10, 10 )
    DLabel:SetText( "Text" )

    local TextEntry = vgui.Create( "DTextEntry", panel ) 
    TextEntry:SetPos( 50, 10 )
    TextEntry:SetSize( 100, 20 )
    TextEntry:SetText( self.text )
    TextEntry.OnChange = function( text_entry )
        self.text = text_entry:GetValue()
    end

    DLabel = vgui.Create( "DLabel", panel )
    DLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    DLabel:SetPos( 10, 30 )
    DLabel:SetText( "Size" )

    local DNumberWang = vgui.Create( "DNumberWang", panel ) 
    DNumberWang:SetPos( 50, 30 )
    DNumberWang:SetSize( 50, 20 )
    DNumberWang:SetValue( self.size )
    DNumberWang.OnValueChanged = function( _, value )
        self.size = tonumber(value) or 2
    end

    DLabel = vgui.Create( "DLabel", panel )
    DLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    DLabel:SetPos( 10, 50 )
    DLabel:SetText( "Font" )

    TextEntry = vgui.Create( "DTextEntry", panel ) 
    TextEntry:SetPos( 50, 50 )
    TextEntry:SetSize( 100, 20 )
    TextEntry:SetText( self.font )
    TextEntry.OnChange = function( text_entry )
        self.font = text_entry:GetValue()
    end

    DLabel = vgui.Create( "DLabel", panel )
    DLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    DLabel:SetPos( 10, 70 )
    DLabel:SetText( "Color" )

    local DColorMixer = vgui.Create( "DColorMixer", panel )
    DColorMixer:SetPos( 50, 70 )
    DColorMixer:SetSize( 300, 150 )
    DColorMixer:SetPalette( true )
    DColorMixer:SetAlphaBar( true )
    DColorMixer:SetWangs( true )
    DColorMixer:SetColor( self.color )
    DColorMixer.ValueChanged = function( panel, col )
        self.color = col
    end

    DLabel = vgui.Create( "DLabel", panel )
    DLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    DLabel:SetPos( 10, 220 )
    DLabel:SetText( "Secondary" )

    local DComboBox = vgui.Create("DComboBox", panel)
    DComboBox:SetPos( 70, 220 )
    DComboBox:SetSize(80, 20)
    DComboBox:SetSortItems(false)
    DComboBox:AddChoice("None", SECONDARY_NONE, self.secondary == SECONDARY_NONE)
    DComboBox:AddChoice("Shadow", SECONDARY_SHADOW, self.secondary == SECONDARY_SHADOW)
    DComboBox:AddChoice("Outline", SECONDARY_OUTLINE, self.secondary == SECONDARY_OUTLINE)
    DComboBox.OnSelect = function(_, _, _, data)
        print(data)
        self.secondary = data
    end

    DLabel = vgui.Create( "DLabel", panel )
    DLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    DLabel:SetPos( 10, 240 )
    DLabel:SetSize(100, 26)
    DLabel:SetText( "Secondary Value" )

    DNumberWang = vgui.Create( "DNumberWang", panel ) 
    DNumberWang:SetPos( 100, 240 )
    DNumberWang:SetSize( 50, 20 )
    DNumberWang:SetValue( self.secondary_value )
    DNumberWang.OnValueChanged = function( _, value )
        self.secondary_value = tonumber(value) or 2
    end

end

function TOOL.DataFunction(data, tbl)
    tbl = TOOL:GetBase().DataFunction(data, tbl)
    tbl.ang = data.ang
    tbl.text = data.text
    tbl.color = data.color
    tbl.font = data.font
    tbl.size = data.size
    tbl.secondary = data.secondary
    tbl.secondary_value = data.secondary_value

    return tbl
end

function TOOL:WriteToBuffer( buffer )
    buffer:WriteFloat(self.ang.p)
    buffer:WriteFloat(self.ang.y)
    buffer:WriteFloat(self.ang.r)

    buffer:WriteString(self.text)

    buffer:WriteFloat(self.color.r)
    buffer:WriteFloat(self.color.g)
    buffer:WriteFloat(self.color.b)
    buffer:WriteFloat(self.color.a)

    buffer:WriteString(self.font)
    buffer:WriteFloat(self.size)
    buffer:WriteUInt8(self.secondary)
    buffer:WriteFloat(self.secondary_value)
end

function TOOL:ReadFromBuffer( buffer )
    self.ang.p = buffer:ReadFloat()
    self.ang.y = buffer:ReadFloat()
    self.ang.r = buffer:ReadFloat()

    self.text = buffer:ReadString()

    self.color.r = buffer:ReadFloat()
    self.color.g = buffer:ReadFloat()
    self.color.b = buffer:ReadFloat()
    self.color.a = buffer:ReadFloat()

    self.font = buffer:ReadString()
    self.size = buffer:ReadFloat()
    self.secondary = buffer:ReadUInt8()
    self.secondary_value = buffer:ReadFloat()
end

if not CLIENT then
    return MapPatcher.RegisterTool(TOOL)
end

local textdraw = function(depth, skybox)
    if skybox or (MapPatcher.CVarDraw:GetBool() and MapPatcher.HasAccess(LocalPlayer())) or MapPatcher.Editor.Enabled then return end

    for _, object in ipairs(MapPatcher.Objects) do
        if object:IsDerivedFrom("text") then
            object:TextDraw()
        end
    end
end

hook.Add("PostDrawTranslucentRenderables", "MapPatcher_TextDraw", textdraw)
hook.Add("PostDrawOpaqueRenderables", "MapPatcher_TextDraw", textdraw)

return MapPatcher.RegisterTool(TOOL)