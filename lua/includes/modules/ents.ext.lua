--[[
    GM Libraries :: ents.* Extension
        by MiBShidobu
]]--

--[[
    Name: ents.CreateFromDuped(table Table)
    Desc: Helper function to create, spawn, and activate entities from dupe structure.

	See duplicator.CopyEntTable( http://wiki.garrysmod.com/page/duplicator/CopyEntTable ) to create dupe structure.

    State: SERVER
]]--

function ents.CreateEntityDuped(tbl)
    local ent = ents.Create(tbl.Class)
    if IsValid(ent) then
        duplicator.DoGeneric(ent, tbl)
        ent:SetPos(Vector(0, 0, 0))
        ent:Spawn()
        ent:Activate()
        duplicator.DoGenericPhysics(ent, tbl)

        return ent

    else
        error("Invalid entity class: " + tostring(tbl.Class))
    end
end