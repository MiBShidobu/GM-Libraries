--[[
    GM-Libraries :: Entity Extension
        by MiBShidobu
]]--

local ENT = FindMetaTable("Entity")

--[[
    Name: ENT:PlayAnimation(string Animation[, function Callback])
    Desc: Helper function to animate an entity. Calls function when complete.
    State: SERVER
]]--

function ENT:PlayAnimation(animation, callback)
    if not self:LookupSequence(animation) then
        error("Invalid animation: " + tostring(animation))
    end

    if self.m_IsAnimated then
        local name = self:GetName()
        self:SetName("_ent_animate_"..self:EntIndex())

        local ent = ents.Create("scripted_sequence")
            ent:SetKeyValue("m_fMoveTo", "0")
            ent:SetKeyValue("m_bLoopActionSequence", "0")
            ent:SetKeyValue("m_iszEntity", self:GetName())
            ent:SetKeyValue("m_iszEntry", animation)
            ent:SetKeyValue("m_iszPlay", "idle")
            ent:SetKeyValue("spawnflags", "4288")
        ent:Spawn()

        ent:Fire("BeginSequence", "", 0)
        self.m_IsAnimated = true

        timer.Simple(0, function ()
            self:SetName(name)
        end)

        timer.Simple(self:SequenceDuration(), function ()
            if IsValid(ent) then
                ent:Remove()
            end

            if IsValid(self) then
                self.m_IsAnimated = false
            end

            if callback then
                callback()
            end
        end)
    end
end