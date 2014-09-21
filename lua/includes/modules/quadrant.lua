--[[
    Quadrant Object Library By MiBShidobu

    Description:
        This addon provides a new Quadrant object functionality for other addons to use. To get help using it, check out
        the wiki.

    Developing For:
        To expand upon the Quadrant object, use FindMetaTable with the parameter "Quadrant" and extend it would like any
        other metatable. Quadrant objects also retain indexed metadata like entities for all runtime. e.g.

            local quadrant = Quadrant(2, 5, 0)
            quadrant.mymetadata = "Ello!"

            print(quadrant.mymetadata) -- prints, Ello!

    Credits:
        MiBShidobu - Main Developer
]]--

local QUADRANT_RADIUS = 600
local QUADRANT_DIAMETER = QUADRANT_RADIUS * 2

local QUADRANT = {}
QUADRANT.__index = QUADRANT

local QUADRANT_DATA = {}

--[[
	Registering Quadrant metatable.
]]--

debug.getregistry().Quadrant = QUADRANT

--[[
    Name: Quadrant(number X, number Y, number Z)
    Desc: Returns quadrant object corresponding to the X, Y, and Z.
    State: SHARED
]]--

function Quadrant(x, y, z)
	x, y, z = math.floor(x), math.floor(y), math.floor(z)
	local id = string.format("%d, %d, %d", x, y, z)
	if not QUADRANT_DATA[id] then
		QUADRANT_DATA[id] = setmetatable({
			x = x,
			y = y,
			z = z
		}, QUADRANT)
	end

	return QUADRANT_DATA[id]
end

--[[
    Name: QuadrantPosition(vector Position)
    Desc: Returns quadrant object corresponding to the world position. (Note: This transforms a world Vector into a Quadrant on the map)
    State: SHARED
]]--

function QuadrantPosition(position)
	local coordinates = position / QUADRANT_DIAMETER	
	return Quadrant(
		coordinates.x,
		coordinates.y,
		coordinates.z
	)
end

--[[
    Name: QuadrantString(string String)
    Desc: Returns parses a "0, 0, 0" string into a quadrant object.
    State: SHARED
]]--

function QuadrantString(str)
	local parts = string.Explode(", ", str)
	return Quadrant(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]))
end

--[[
    Name: IsQuadrant(any Var)
    Desc: Returns if the variable is a quadrant or not.
    State: SHARED
]]--

function IsQuadrant(obj)
	return getmetatable(obj) == QUADRANT
end

--[[
    Name: GetQuadrantRadius()
    Desc: Returns the radius of a quadrant.
    State: SHARED
]]--

function GetQuadrantRadius()
	return QUADRANT_RADIUS
end

--[[
    Name: GetQuadrantDiameter(any Var)
    Desc: Returns the diameter of a quadrant.
    State: SHARED
]]--

function GetQuadrantDiameter()
	return QUADRANT_DIAMETER
end

--[[
    Name: QUADRANT:__tostring()
    Desc: Returns the string form of the quadrant.
    State: SHARED
]]--

function QUADRANT:__tostring()
	return string.format("%d, %d, %d", self.x, self.y, self.z)
end

--[[
    Name: QUADRANT:__eq(quadrant Quadrant)
    Desc: Returns two quadrants equal each other.
    State: SHARED
]]--

function QUADRANT:__eq(quadrant)
	return self.x == quadrant.x and self.y == quadrant.y and self.z == quadrant.z
end

--[[
    Name: QUADRANT:GetMins()
    Desc: Returns the minimum bounding box. 
    State: SHARED
]]--

function QUADRANT:GetMins()
	return -Vector(QUADRANT_RADIUS, QUADRANT_RADIUS, QUADRANT_RADIUS)
end

--[[
    Name: QUADRANT:GetMaxs()
    Desc: Returns the maximum bounding box.
    State: SHARED
]]--

function QUADRANT:GetMaxs()
	return Vector(QUADRANT_RADIUS, QUADRANT_RADIUS, QUADRANT_RADIUS)
end

--[[
    Name: QUADRANT:GetPos()
    Desc: Returns the world position of the quadrant.
    State: SHARED
]]--

function QUADRANT:GetPos()
	return Vector((self.x * QUADRANT_DIAMETER) + QUADRANT_RADIUS, (self.y * QUADRANT_DIAMETER) + QUADRANT_RADIUS, (self.z * QUADRANT_DIAMETER) + QUADRANT_RADIUS)
end

--[[
    Name: QUADRANT:WorldToLocal(vector Position)
    Desc: Returns localized version of the position.
    State: SHARED
]]--

function QUADRANT:WorldToLocal(position)
	local vector = WorldToLocal(position, Angle(), self:GetPos(), Angle())
	return vector
end

--[[
    Name: QUADRANT:LocalToWorld(vector Position)
    Desc: Returns world version of the position.
    State: SHARED
]]--

function QUADRANT:LocalToWorld(position)
	local vector, _ = LocalToWorld(position, Angle(), self:GetPos(), Angle())
	return vector
end

--[[
    Name: QUADRANT:IsAirborne()
    Desc: Returns if the quadrant is in the air or not.
    State: SHARED
]]--

function QUADRANT:IsAirborne()
	local time = CurTime()
	if self.LastAirTrace ~= time then
		local position = self:LocalToWorld(Vector(0, 0, -QUADRANT_RADIUS))
		self.AirTrace = util.TraceHull{
			start = position,
			endpos = position,
			mins = -Vector(QUADRANT_RADIUS, QUADRANT_RADIUS, 2.5),
			maxs = Vector(QUADRANT_RADIUS, QUADRANT_RADIUS, 2.5),
			mask = MASK_SOLID_BRUSHONLY
		}

		self.LastAirTrace = time
	end

	return not self.AirTrace.Hit
end

--[[
    Name: QUADRANT:GetDistrict()
    Desc: Returns the district the Quadrant is in.
    State: SHARED
]]--

local DISTRICT_DIAMETER = 2

function QUADRANT:GetDistrict()
    return math.floor(self.x / DISTRICT_DIAMETER), math.floor(self.y / DISTRICT_DIAMETER)
end

--[[
    Name: QUADRANT:GetDistrictPos()
    Desc: Returns the localized position of the Quadrant relative to the district.
    State: SHARED
]]--

function QUADRANT:GetDistrictPos()
    local dx, dy = self:GetDistrict()
    return self.x - (dx * 2), self.y - (dy * 2)
end

--[[
    Name: QUADRANT:GetName()
    Desc: Returns a Greek alphabet name, based on the Quadrant's position inside a district.
    State: SHARED
]]--

local QUADRANT_NAMES = {
    ["00"] = "Nu",
    ["01"] = "Psi",
    ["10"] = "Tau",
    ["11"] = "Theta"
}

function QUADRANT:GetName()
    if not self.LegibleName then
        local dx, dy = self:GetDistrictPos()
        self.LegibleName = QUADRANT_NAMES[dx..dy]
    end

    return self.LegibleName
end

--[[
    Name: GenerateSyllable()
    Desc: Returns a randomly generated syllable
    State: LOCAL/SHARED
]]--

local vowels = "aeiou"
local consonants = "bcdfghjklmnprstvwz"
local letters = vowels..consonants

local function GenerateSyllable()
    local text = ""
    for index = 1, 3 do
        if index == 1 then
            text = letters[math.Rand(1, #letters)]

        elseif index == 2 and string.find(vowels, text[index - 1], nil, false) then
            text = text..consonants[math.Rand(1, #consonants)]

        elseif string.find(consonants, text[index - 1], nil, false) then
            text = text..vowels[math.Rand(1, #vowels)]
        end
    end

    return text
end

--[[
    Name: QUADRANT:GetDistrictName()
    Desc: Returns a randomly named district based on map and district's position.
    State: SHARED
]]--

function QUADRANT:GetDistrictName()
    if not self.LegibleDistrict then
        local dx, dy = self:GetDistrict()
        local seed = util.CRC(string.format(
            "%d:%d:%s",
            dx,
            dy,
            map
        ))

        math.randomseed(seed)

        local first = GenerateSyllable()
        local name = string.upper(first[1])..string.sub(first, 2)..GenerateSyllable()

        self.LegibleDistrict = name
    end

    return self.LegibleDistrict
end