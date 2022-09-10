local TOOL = {}
TOOL.Base = "base"

function TOOL:IsValid()
    return false
end

return MapPatcher.RegisterTool(TOOL)