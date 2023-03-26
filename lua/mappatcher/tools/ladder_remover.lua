local TOOL = {}
--------------------------------------------------------------------------------
TOOL.EditorMenu = true
TOOL.Base = "base_brush"
TOOL.Description = "Removes any func_useableladder it touches. It can touch a ladder's corner to delete it."
--------------------------------------------------------------------------------
TOOL.TextureColor = Color(230, 255, 0, 125)
TOOL.TextureText = "Ladder Remover"
--------------------------------------------------------------------------------
--local VEC_HULL_MIN = Vector(-16, -16, 0)
--local VEC_HULL_MAX = Vector(16,  16,  72)

local ladderPoints = {
	Vector(-16, -16, -36), Vector(16, -16, -36), Vector(-16, 16, -36), Vector(16, 16, -36),
	Vector(-16, -16, 36), Vector(16, -16, 36), Vector(-16, 16, 36), Vector(16, 16, 36),
}

function TOOL:EntSetup(ent)
	ent:SetSolidFlags(FSOLID_CUSTOMBOXTEST)
	if not SERVER then return end

	local min = Vector()
	local max = Vector()

	for k, point in pairs(self.points) do
		local lp = point
		min.x = math.min(min.x, lp.x)
		min.y = math.min(min.y, lp.y)
		min.z = math.min(min.z, lp.z)
		max.x = math.max(max.x, lp.x)
		max.y = math.max(max.y, lp.y)
		max.z = math.max(max.z, lp.z)
	end

	-- Delete old ladders
	for _, ladder in ipairs(ents.FindByClass("func_useableladder")) do
		local pos = ladder:GetPos()
		local point0 = pos + ladder:GetInternalVariable("point0")
		local point1 = pos + ladder:GetInternalVariable("point1")

		for _, point in ipairs(ladderPoints) do
			if (point0 + point):WithinAABox(min, max) or (point1 + point):WithinAABox(min, max) then
				ladder:Remove()
				break
			end
		end
	end
end

function TOOL:EntShouldCollide(ent)
	return false
end
--------------------------------------------------------------------------------
return MapPatcher.RegisterTool(TOOL)