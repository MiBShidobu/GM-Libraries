--[[
    GM-Libraries :: Brush Detection Box
        By MiBShidobu
]]--

ENT.Base = "base_brush"
ENT.Type = "brush"

if SERVER then
    AccessorFunc(ENT, "m_StartFunc", "Start")
    AccessorFunc(ENT, "m_StopFunc", "Stop")
    AccessorFunc(ENT, "m_FilterFunc", "Filter")

    --[[
        Name: ENT:Initialize()
        Desc: Called when the entity is created to do some pre-spawn related stuff.
        State: SERVER
    ]]--

    function ENT:Initialize()
        self:SetSolid(SOLID_BBOX)
        self:SetTrigger(true)

        --self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    end

    --[[
        Name: ENT:GetDetectionBounds()
        Desc: Returns the collision bounds of the detection entity.
        State: SERVER
    ]]--

    function ENT:GetDetectionBounds()
        return self:GetCollisionBounds()
    end

    --[[
        Name: ENT:SetDetectionBounds(vector Mins, vector Maxs)
        Desc: Sets the collision bounds of the detection entity.
        State: SERVER
    ]]--

    function ENT:SetDetectionBounds(mins, maxs)
        self:SetCollisionBounds(mins, maxs)
    end

    --[[
        Name: ENT:SetDetectionRadius(number Radius)
        Desc: Sets the collision radius of the detection entity, alternative to Bounds to purely make a box shaped radius.
        State: SERVER
    ]]--

    function ENT:SetDetectionRadius(radius)
        self:SetDetectionBounds(-Vector(radius, radius, radius), Vector(radius, radius, radius))
    end

    --[[
        Name: ENT:GetLastTouch()
        Desc: Returns the last entity to successfully touch and pass the filter.
        State: SERVER
    ]]--

    function ENT:GetLastTouch()
        return self.m_LastTouch
    end

    --[[
        Name: ENT:CheckTouch(entity Entity, function Callback)
        Desc: Checks if the entity passes the filter and then calls the callback.
        State: SERVER
    ]]--

    function ENT:CheckTouch(ent, callback)
        if callback then
            if not self.m_FilterFunc or self:m_FilterFunc(ent) then
                callback(self, ent)

                self.m_LastTouch = ent
            end
        end
    end

    ENT.StartTouch = function (self, ent) self:CheckTouch(ent, self.m_StartFunc) end
    ENT.EndTouch = function (self, ent) self:CheckTouch(ent, self.m_StopFunc) end
end